import 'package:dartz/dartz.dart';
import 'package:snap_notes/core/error/failures.dart';
import 'package:snap_notes/core/usecase/usecase.dart';
import 'package:snap_notes/features/auth/domain/entities/pengguna.dart';
import 'package:snap_notes/features/auth/domain/repositories/auth_repository.dart';

class GetProfil implements UseCase<Pengguna, NoParams> {
  final AuthRepository repository;

  GetProfil(this.repository);

  @override
  Future<Either<Failure, Pengguna>> call(NoParams params) {
    return repository.getProfil();
  }
}
