import 'package:dartz/dartz.dart';
import 'package:snap_notes/core/error/failures.dart';
import 'package:snap_notes/core/usecase/usecase.dart';
import 'package:snap_notes/features/auth/domain/entities/auth_token.dart';
import 'package:snap_notes/features/auth/domain/repositories/auth_repository.dart';

class MasukDenganGoogle implements UseCase<AuthToken, NoParams> {
  final AuthRepository repository;

  MasukDenganGoogle(this.repository);

  @override
  Future<Either<Failure, AuthToken>> call(NoParams params) {
    return repository.masukDenganGoogle();
  }
}
