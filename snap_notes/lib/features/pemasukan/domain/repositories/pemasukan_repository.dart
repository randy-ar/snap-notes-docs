import 'package:dartz/dartz.dart';
import 'package:snap_notes/core/error/failures.dart';
import 'package:snap_notes/features/pemasukan/domain/entities/pemasukan.dart';

abstract class PemasukanRepository {
  Future<Either<Failure, Pemasukan>> tambahPemasukan({
    required String deskripsi,
    required double jumlah,
    required DateTime tanggal,
    String? kategoriId,
    String? catatan,
  });

  Future<Either<Failure, List<Pemasukan>>> getDaftarPemasukan({
    int? bulan,
    int? tahun,
  });

  Future<Either<Failure, Pemasukan>> getPemasukanDetail(String id);

  Future<Either<Failure, Pemasukan>> updatePemasukan(
    String id, {
    String? deskripsi,
    double? jumlah,
    DateTime? tanggal,
    String? kategoriId,
    String? catatan,
  });

  Future<Either<Failure, void>> hapusPemasukan(String id);
}
