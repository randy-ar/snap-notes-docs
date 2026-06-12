import 'package:equatable/equatable.dart';

class AuthToken extends Equatable {
  final String accessToken;
  final String refreshToken;
  final String userId;
  final String email;

  const AuthToken({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.email,
  });

  @override
  List<Object> get props => [accessToken, refreshToken, userId, email];
}
