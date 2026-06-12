import 'package:dartz/dartz.dart';
import 'package:snap_notes/core/error/failures.dart';
import 'package:snap_notes/features/pengeluaran/domain/entities/pengeluaran.dart';

abstract class PengeluaranRepository {
  Future<Either<Failure, Pengeluaran>> tambahPengeluaran({
    required String deskripsi,
    required double jumlah,
    required DateTime tanggal,
    String? kategoriId,
    String? catatan,
  });

  Future<Either<Failure, List<Pengeluaran>>> getDaftarPengeluaran({
    int? bulan,
    int? tahun,
  });

  Future<Either<Failure, Pengeluaran>> getPengeluaranDetail(String id);

  Future<Either<Failure, Pengeluaran>> updatePengeluaran(
    String id, {
    String? deskripsi,
    double? jumlah,
    DateTime? tanggal,
    String? kategoriId,
    String? catatan,
  });

  Future<Either<Failure, void>> hapusPengeluaran(String id);
}
