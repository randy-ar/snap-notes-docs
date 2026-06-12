import 'package:equatable/equatable.dart';
import 'package:snap_notes/features/auth/domain/entities/pengguna.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final Pengguna pengguna;

  const AuthAuthenticated(this.pengguna);

  @override
  List<Object?> get props => [pengguna];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
