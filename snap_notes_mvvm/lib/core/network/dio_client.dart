import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:snap_notes_mvvm/core/network/auth_interceptor.dart';

class DioClient {
  late final Dio dio;
  final GlobalKey<NavigatorState> navigatorKey;

  DioClient({FlutterSecureStorage? storage, required this.navigatorKey}) {
    dio = Dio(
      BaseOptions(
        baseUrl: dotenv.env['NESTJS_SERVER_URL'] ?? 'http://localhost:3000',
        connectTimeout: const Duration(seconds: 120),
        receiveTimeout: const Duration(seconds: 300),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    if (storage != null) {
      dio.interceptors.add(AuthInterceptor(storage: storage, navigatorKey: navigatorKey));
    }

    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ),
    );
  }
}
