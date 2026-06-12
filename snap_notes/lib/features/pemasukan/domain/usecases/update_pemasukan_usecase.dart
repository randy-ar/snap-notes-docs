import 'package:dartz/dartz.dart';
import 'package:snap_notes/core/error/failures.dart';
import 'package:snap_notes/features/pemasukan/domain/entities/pemasukan.dart';
import 'package:snap_notes/features/pemasukan/domain/repositories/pemasukan_repository.dart';

class UpdatePemasukanUseCase {
  final PemasukanRepository repository;

  UpdatePemasukanUseCase(this.repository);

  Future<Either<Failure, Pemasukan>> call(
    String id, {
    String? deskripsi,
    double? jumlah,
    DateTime? tanggal,
    String? kategoriId,
    String? catatan,
  }) async {
    return await repository.updatePemasukan(
      id,
      deskripsi: deskripsi,
      jumlah: jumlah,
      tanggal: tanggal,
      kategoriId: kategoriId,
      catatan: catatan,
    );
  }
}
