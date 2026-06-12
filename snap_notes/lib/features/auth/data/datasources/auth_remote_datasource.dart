import 'package:dio/dio.dart';
import 'package:snap_notes/core/error/exceptions.dart';
import 'package:snap_notes/features/auth/data/models/auth_token_model.dart';
import 'package:snap_notes/features/auth/data/models/pengguna_model.dart';

abstract class AuthRemoteDataSource {
  /// POST /auth/masuk — login email/password
  Future<AuthTokenModel> masuk(String email, String password);

  /// POST /auth/daftar — registrasi akun baru
  Future<PenggunaModel> daftar(String email, String password, String namaLengkap);

  /// POST /auth/keluar — logout & invalidate refresh token di server
  Future<void> keluar(String refreshToken);

  /// POST /auth/refresh — perbarui access token
  Future<AuthTokenModel> refreshToken(String refreshToken);

  /// GET /auth/profil — ambil data profil pengguna
  Future<PenggunaModel> getProfil();

  /// PATCH /auth/profil — update profil pengguna
  Future<PenggunaModel> updateProfil({String? namaLengkap, String? fotoProfilUrl});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<AuthTokenModel> masuk(String email, String password) async {
    try {
      final response = await dio.post(
        '/api/auth/masuk',
        data: {'email': email, 'password': password},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final envelope = response.data as Map<String, dynamic>;
        return AuthTokenModel.fromJson(envelope['data'] as Map<String, dynamic>);
      }
      throw ServerException('Login gagal: ${response.statusCode}');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException('Email atau password salah');
      }
      throw ServerException(e.message ?? 'Terjadi kesalahan jaringan');
    }
  }

  @override
  Future<PenggunaModel> daftar(
    String email,
    String password,
    String namaLengkap,
  ) async {
    try {
      final response = await dio.post(
        '/api/auth/daftar',
        data: {'email': email, 'password': password, 'namaLengkap': namaLengkap},
      );
      if (response.statusCode == 201) {
        final envelope = response.data as Map<String, dynamic>;
        final data = envelope['data'] as Map<String, dynamic>;
        return PenggunaModel(
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

  @override
  Future<void> keluar(String refreshToken) async {
    try {
      await dio.post('/api/auth/keluar', data: {'refreshToken': refreshToken});
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Terjadi kesalahan jaringan');
    }
  }

  @override
  Future<AuthTokenModel> refreshToken(String refreshToken) async {
    try {
      final response = await dio.post(
        '/api/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      if (response.statusCode == 200) {
        final envelope = response.data as Map<String, dynamic>;
        return AuthTokenModel.fromJson(envelope['data'] as Map<String, dynamic>);
      }
      throw ServerException('Refresh token gagal: ${response.statusCode}');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException('Refresh token tidak valid atau kadaluarsa');
      }
      throw ServerException(e.message ?? 'Terjadi kesalahan jaringan');
    }
  }

  @override
  Future<PenggunaModel> getProfil() async {
    try {
      final response = await dio.get('/api/auth/profil');
      if (response.statusCode == 200) {
        final envelope = response.data as Map<String, dynamic>;
        return PenggunaModel.fromJson(envelope['data'] as Map<String, dynamic>);
      }
      throw ServerException('Gagal mengambil profil: ${response.statusCode}');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException('Sesi tidak valid, silakan login kembali');
      }
      throw ServerException(e.message ?? 'Terjadi kesalahan jaringan');
    }
  }

  @override
  Future<PenggunaModel> updateProfil({
    String? namaLengkap,
    String? fotoProfilUrl,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (namaLengkap != null) data['namaLengkap'] = namaLengkap;
      if (fotoProfilUrl != null) data['fotoProfilUrl'] = fotoProfilUrl;

      final response = await dio.patch('/api/auth/profil', data: data);
      if (response.statusCode == 200) {
        final envelope = response.data as Map<String, dynamic>;
        return PenggunaModel.fromJson(envelope['data'] as Map<String, dynamic>);
      }
      throw ServerException('Gagal update profil: ${response.statusCode}');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException('Sesi tidak valid, silakan login kembali');
      }
      throw ServerException(e.message ?? 'Terjadi kesalahan jaringan');
    }
  }
}
