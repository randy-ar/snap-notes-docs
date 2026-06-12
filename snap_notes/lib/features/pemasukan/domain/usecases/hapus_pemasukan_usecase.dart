import 'package:dartz/dartz.dart';
import 'package:snap_notes/core/error/failures.dart';
import 'package:snap_notes/features/pemasukan/domain/repositories/pemasukan_repository.dart';

class HapusPemasukanUseCase {
  final PemasukanRepository repository;

  HapusPemasukanUseCase(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    return await repository.hapusPemasukan(id);
  }
}
