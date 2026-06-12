import 'package:equatable/equatable.dart';
import 'package:snap_notes/features/auth/domain/entities/pengguna.dart';

abstract class RegisterState extends Equatable {
  const RegisterState();

  @override
  List<Object?> get props => [];
}

class RegisterInitial extends RegisterState {
  const RegisterInitial();
}

class RegisterLoading extends RegisterState {
  const RegisterLoading();
}

class RegisterSuccess extends RegisterState {
  final Pengguna pengguna;

  const RegisterSuccess(this.pengguna);

  @override
  List<Object?> get props => [pengguna];
}

class RegisterError extends RegisterState {
  final String message;

  const RegisterError(this.message);

  @override
  List<Object?> get props => [message];
}
