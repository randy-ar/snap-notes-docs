import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:snap_notes_mvvm/core/di/injection.dart';
import 'package:snap_notes_mvvm/features/auth/viewmodels/auth_viewmodel.dart';
/// Interceptor yang otomatis menyisipkan Bearer token ke setiap request.
/// Token diambil dari FlutterSecureStorage dengan key 'access_token'.
class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage storage;

  static const _accessTokenKey = 'access_token';

  AuthInterceptor({required this.storage});

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await storage.read(key: _accessTokenKey);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      getIt<AuthViewModel>().logout();
    }
    handler.next(err);
  }
}
