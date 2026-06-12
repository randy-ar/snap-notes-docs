import 'package:dartz/dartz.dart';
import 'package:snap_notes/core/error/failures.dart';
import 'package:snap_notes/features/pengeluaran/domain/entities/pengeluaran.dart';
import 'package:snap_notes/features/pengeluaran/domain/repositories/pengeluaran_repository.dart';

class GetPengeluaranDetailUseCase {
  final PengeluaranRepository repository;

  GetPengeluaranDetailUseCase(this.repository);

  Future<Either<Failure, Pengeluaran>> call(String id) async {
    return await repository.getPengeluaranDetail(id);
  }
}
