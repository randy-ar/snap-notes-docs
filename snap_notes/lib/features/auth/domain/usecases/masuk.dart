import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:snap_notes/core/error/failures.dart';
import 'package:snap_notes/core/usecase/usecase.dart';
import 'package:snap_notes/features/auth/domain/entities/auth_token.dart';
import 'package:snap_notes/features/auth/domain/repositories/auth_repository.dart';

class Masuk implements UseCase<AuthToken, MasukParams> {
  final AuthRepository repository;

  Masuk(this.repository);

  @override
  Future<Either<Failure, AuthToken>> call(MasukParams params) {
    return repository.masuk(params.email, params.password);
  }
}

class MasukParams extends Equatable {
  final String email;
  final String password;

  const MasukParams({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}
