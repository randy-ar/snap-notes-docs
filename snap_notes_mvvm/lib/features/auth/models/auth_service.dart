import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:snap_notes_mvvm/core/error/exceptions.dart';
import 'package:snap_notes_mvvm/features/auth/models/auth_token.dart';
import 'package:snap_notes_mvvm/features/auth/models/pengguna.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service untuk autentikasi - menggabungkan Remote, Local, dan Supabase datasource
class AuthService {
  final Dio _dio;
  final FlutterSecureStorage _storage;
  final SupabaseClient _supabaseClient;

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userIdKey = 'user_id';
  static const _emailKey = 'user_email';

  AuthService({
    required this._dio,
    required this._storage,
    required this._supabaseClient,
  });

  /// Login dengan email dan password
  Future<AuthToken> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/api/auth/masuk',
        data: {'email': email, 'password': password},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final envelope = response.data as Map<String, dynamic>;
        final token = AuthToken.fromJson(envelope['data'] as Map<String, dynamic>);
        await _saveToken(token);
        return token;
      }
      throw ServerException('Login gagal: ${response.statusCode}');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException('Email atau password salah');
      }
      throw ServerException(e.message ?? 'Terjadi kesalahan jaringan');
    }
  }

  /// Login dengan Google OAuth via Supabase
  Future<AuthToken> loginWithGoogle() async {
    try {
      await _supabaseClient.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'snapnotes://auth',
        authScreenLaunchMode: LaunchMode.externalApplication,
      );

      final session = await _waitForSession();
      if (session == null) {
        throw OAuthException('Login Google dibatalkan atau gagal');
      }

      final token = _sessionToToken(session);
      await _saveToken(token);
      return token;
    } on OAuthException {
      rethrow;
    } catch (e) {
      throw OAuthException('Login Google gagal: ${e.toString()}');
    }
  }

  /// Registrasi akun baru
  Future<Pengguna> register(String email, String password, String namaLengkap) async {
    try {
      final response = await _dio.post(
        '/api/auth/daftar',
        data: {'email': email, 'password': password, 'namaLengkap': namaLengkap},
      );
      if (response.statusCode == 201) {
        final envelope = response.data as Map<String, dynamic>;
        final data = envelope['data'] as Map<String, dynamic>;
        return Pengguna(
          id: data['userId'] as String,
          email: data['email'] as String,
          namaLengkap: namaLengkap,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }
      throw ServerException('Pendaftaran gagal: ${response.statusCode}');
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw ServerException('Email sudah terdaftar');
      }
      throw ServerException(e.message ?? 'Terjadi kesalahan jaringan');
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      final token = await _getToken();
      if (token != null) {
        try {
          await _dio.post('/api/auth/keluar', data: {'refreshToken': token.refreshToken});
        } catch (_) {
          // Lanjutkan logout lokal meskipun server error
        }
      }
      try {
        await _supabaseClient.auth.signOut();
      } catch (_) {
        // Lanjutkan hapus token lokal
      }
      await _deleteToken();
    } on LocalException {
      rethrow;
    } catch (e) {
      throw LocalException('Gagal logout: ${e.toString()}');
    }
  }

  /// Ambil profil pengguna
  Future<Pengguna> getProfile() async {
    try {
      final response = await _dio.get('/api/auth/profil');
      if (response.statusCode == 200) {
        final envelope = response.data as Map<String, dynamic>;
        return Pengguna.fromJson(envelope['data'] as Map<String, dynamic>);
      }
      throw ServerException('Gagal mengambil profil: ${response.statusCode}');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException('Sesi tidak valid, silakan login kembali');
      }
      throw ServerException(e.message ?? 'Terjadi kesalahan jaringan');
    }
  }

  /// Update profil pengguna
  Future<Pengguna> updateProfile({String? namaLengkap, String? fotoProfilUrl}) async {
    try {
      final data = <String, dynamic>{};
      if (namaLengkap != null) data['namaLengkap'] = namaLengkap;
      if (fotoProfilUrl != null) data['fotoProfilUrl'] = fotoProfilUrl;

      final response = await _dio.patch('/api/auth/profil', data: data);
      if (response.statusCode == 200) {
        final envelope = response.data as Map<String, dynamic>;
        return Pengguna.fromJson(envelope['data'] as Map<String, dynamic>);
      }
      throw ServerException('Gagal update profil: ${response.statusCode}');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException('Sesi tidak valid, silakan login kembali');
      }
      throw ServerException(e.message ?? 'Terjadi kesalahan jaringan');
    }
  }

  /// Cek apakah user sudah login
  Future<bool> isAuthenticated() async {
    final token = await _storage.read(key: _accessTokenKey);
    return token != null && token.isNotEmpty;
  }

  /// Get current token
  Future<AuthToken?> getCurrentToken() async {
    return await _getToken();
  }

  // Private helper methods
  Future<void> _saveToken(AuthToken token) async {
    try {
      await Future.wait([
        _storage.write(key: _accessTokenKey, value: token.accessToken),
        _storage.write(key: _refreshTokenKey, value: token.refreshToken),
        _storage.write(key: _userIdKey, value: token.userId),
        _storage.write(key: _emailKey, value: token.email),
      ]);
    } catch (e) {
      throw LocalException('Gagal menyimpan token: ${e.toString()}');
    }
  }

  Future<AuthToken?> _getToken() async {
    try {
      final accessToken = await _storage.read(key: _accessTokenKey);
      final refreshToken = await _storage.read(key: _refreshTokenKey);
      final userId = await _storage.read(key: _userIdKey);
      final email = await _storage.read(key: _emailKey);

      if (accessToken == null || refreshToken == null || userId == null || email == null) {
        return null;
      }

      return AuthToken(
        accessToken: accessToken,
        refreshToken: refreshToken,
        userId: userId,
        email: email,
      );
    } catch (e) {
      throw LocalException('Gagal membaca token: ${e.toString()}');
    }
  }

  Future<void> _deleteToken() async {
    try {
      await Future.wait([
        _storage.delete(key: _accessTokenKey),
        _storage.delete(key: _refreshTokenKey),
        _storage.delete(key: _userIdKey),
        _storage.delete(key: _emailKey),
      ]);
    } catch (e) {
      throw LocalException('Gagal menghapus token: ${e.toString()}');
    }
  }

  Future<Session?> _waitForSession() async {
    final currentSession = _supabaseClient.auth.currentSession;
    if (currentSession != null) return currentSession;

    try {
      final session = await _supabaseClient.auth.onAuthStateChange
          .where((event) => event.event == AuthChangeEvent.signedIn)
          .map((event) => event.session)
          .first
          .timeout(const Duration(seconds: 60));
      return session;
    } catch (_) {
      return null;
    }
  }

  AuthToken _sessionToToken(Session session) {
    final user = session.user;
    return AuthToken(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken ?? '',
      userId: user.id,
      email: user.email ?? '',
    );
  }
}
