import 'package:snap_notes/features/auth/domain/entities/auth_token.dart';

class AuthTokenModel {
  final String accessToken;
  final String refreshToken;
  final String userId;
  final String email;

  const AuthTokenModel({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.email,
  });

  factory AuthTokenModel.fromJson(Map<String, dynamic> json) {
    return AuthTokenModel(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      userId: json['userId'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'userId': userId,
      'email': email,
    };
  }

  AuthToken toEntity() {
    return AuthToken(
      accessToken: accessToken,
      refreshToken: refreshToken,
      userId: userId,
      email: email,
    );
  }

  factory AuthTokenModel.fromEntity(AuthToken entity) {
    return AuthTokenModel(
      accessToken: entity.accessToken,
      refreshToken: entity.refreshToken,
      userId: entity.userId,
      email: entity.email,
    );
  }
}
