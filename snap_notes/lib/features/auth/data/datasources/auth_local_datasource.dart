import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:snap_notes/core/error/exceptions.dart';
import 'package:snap_notes/features/auth/data/models/auth_token_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveToken(AuthTokenModel token);
  Future<AuthTokenModel?> getToken();
  Future<void> deleteToken();
  Future<bool> isAuthenticated();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage storage;

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userIdKey = 'user_id';
  static const _emailKey = 'user_email';

  AuthLocalDataSourceImpl({required this.storage});

  @override
  Future<void> saveToken(AuthTokenModel token) async {
    try {
      await Future.wait([
        storage.write(key: _accessTokenKey, value: token.accessToken),
        storage.write(key: _refreshTokenKey, value: token.refreshToken),
        storage.write(key: _userIdKey, value: token.userId),
        storage.write(key: _emailKey, value: token.email),
      ]);
    } catch (e) {
      throw LocalException('Gagal menyimpan token: ${e.toString()}');
    }
  }

  @override
  Future<AuthTokenModel?> getToken() async {
    try {
      final accessToken = await storage.read(key: _accessTokenKey);
      final refreshToken = await storage.read(key: _refreshTokenKey);
      final userId = await storage.read(key: _userIdKey);
      final email = await storage.read(key: _emailKey);

      if (accessToken == null || refreshToken == null || userId == null || email == null) {
        return null;
      }

      return AuthTokenModel(
        accessToken: accessToken,
        refreshToken: refreshToken,
        userId: userId,
        email: email,
      );
    } catch (e) {
      throw LocalException('Gagal membaca token: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteToken() async {
    try {
      await Future.wait([
        storage.delete(key: _accessTokenKey),
        storage.delete(key: _refreshTokenKey),
        storage.delete(key: _userIdKey),
        storage.delete(key: _emailKey),
      ]);
    } catch (e) {
      throw LocalException('Gagal menghapus token: ${e.toString()}');
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await storage.read(key: _accessTokenKey);
    return token != null && token.isNotEmpty;
  }
}
