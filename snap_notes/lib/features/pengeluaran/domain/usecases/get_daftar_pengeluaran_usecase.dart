import 'package:dartz/dartz.dart';
import 'package:snap_notes/core/error/failures.dart';
import 'package:snap_notes/features/pengeluaran/domain/entities/pengeluaran.dart';
import 'package:snap_notes/features/pengeluaran/domain/repositories/pengeluaran_repository.dart';

class GetDaftarPengeluaranUseCase {
  final PengeluaranRepository repository;

  GetDaftarPengeluaranUseCase(this.repository);

  Future<Either<Failure, List<Pengeluaran>>> call({int? bulan, int? tahun}) async {
    return await repository.getDaftarPengeluaran(bulan: bulan, tahun: tahun);
  }
}
