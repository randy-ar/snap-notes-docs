import 'package:dartz/dartz.dart';
import 'package:snap_notes/core/error/failures.dart';
import 'package:snap_notes/features/pengeluaran/domain/repositories/pengeluaran_repository.dart';

class HapusPengeluaranUseCase {
  final PengeluaranRepository repository;

  HapusPengeluaranUseCase(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    return await repository.hapusPengeluaran(id);
  }
}
