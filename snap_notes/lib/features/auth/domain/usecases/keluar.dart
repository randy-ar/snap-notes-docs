import 'package:dartz/dartz.dart';
import 'package:snap_notes/core/error/failures.dart';
import 'package:snap_notes/core/usecase/usecase.dart';
import 'package:snap_notes/features/auth/domain/repositories/auth_repository.dart';

class Keluar implements UseCase<void, NoParams> {
  final AuthRepository repository;

  Keluar(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.keluar();
  }
}
