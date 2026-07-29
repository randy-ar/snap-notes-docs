import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:snap_notes_mvvm/core/di/injection.dart';
import 'package:snap_notes_mvvm/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:snap_notes_mvvm/core/utils/toast_formatter.dart';

/// Interceptor yang otomatis menyisipkan Bearer token ke setiap request.
/// Token diambil dari FlutterSecureStorage dengan key 'access_token'.
class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage storage;
  final GlobalKey<NavigatorState> navigatorKey;

  static const _accessTokenKey = 'access_token';

  AuthInterceptor({required this.storage, required this.navigatorKey});

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
    } else {
      final context = navigatorKey.currentContext;
      if (context != null) {
        String errorMessage = 'Terjadi kesalahan pada jaringan.';
        if (err.response?.data != null && err.response?.data is Map) {
          final data = err.response?.data as Map<String, dynamic>;
          if (data.containsKey('message')) {
            final msg = data['message'];
            if (msg is List && msg.isNotEmpty) {
              errorMessage = msg.first.toString();
            } else {
              errorMessage = msg.toString();
            }
          }
        } else if (err.message != null) {
          errorMessage = err.message!;
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          showToast(
            context: context,
            builder: (context, overlay) => ToastFormatter.error('Kesalahan', errorMessage),
            location: ToastLocation.bottomRight,
          );
        });
      }
    }
    handler.next(err);
  }
}
