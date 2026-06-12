import 'package:dartz/dartz.dart';
import 'package:snap_notes/core/error/failures.dart';
import 'package:snap_notes/features/pengeluaran/domain/entities/pengeluaran.dart';
import 'package:snap_notes/features/pengeluaran/domain/repositories/pengeluaran_repository.dart';

class UpdatePengeluaranUseCase {
  final PengeluaranRepository repository;

  UpdatePengeluaranUseCase(this.repository);

  Future<Either<Failure, Pengeluaran>> call(
    String id, {
    String? deskripsi,
    double? jumlah,
    DateTime? tanggal,
    String? kategoriId,
    String? catatan,
  }) async {
    return await repository.updatePengeluaran(
      id,
      deskripsi: deskripsi,
      jumlah: jumlah,
      tanggal: tanggal,
      kategoriId: kategoriId,
      catatan: catatan,
    );
  }
}
