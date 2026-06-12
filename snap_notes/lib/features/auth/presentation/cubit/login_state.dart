import 'package:equatable/equatable.dart';
import 'package:snap_notes/features/auth/domain/entities/auth_token.dart';

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object?> get props => [];
}

class LoginInitial extends LoginState {
  const LoginInitial();
}

class LoginLoading extends LoginState {
  const LoginLoading();
}

class LoginGoogleLoading extends LoginState {
  const LoginGoogleLoading();
}

class LoginSuccess extends LoginState {
  final AuthToken token;

  const LoginSuccess(this.token);

  @override
  List<Object?> get props => [token];
}

class LoginError extends LoginState {
  final String message;

  const LoginError(this.message);

  @override
  List<Object?> get props => [message];
}
