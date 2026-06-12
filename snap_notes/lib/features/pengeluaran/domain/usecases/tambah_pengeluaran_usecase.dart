import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:snap_notes/core/error/failures.dart';
import 'package:snap_notes/core/usecase/usecase.dart';
import 'package:snap_notes/features/pengeluaran/domain/entities/pengeluaran.dart';
import 'package:snap_notes/features/pengeluaran/domain/repositories/pengeluaran_repository.dart';

class TambahPengeluaranUseCase implements UseCase<Pengeluaran, TambahPengeluaranParams> {
  final PengeluaranRepository repository;

  TambahPengeluaranUseCase(this.repository);

  @override
  Future<Either<Failure, Pengeluaran>> call(TambahPengeluaranParams params) async {
    return await repository.tambahPengeluaran(
      deskripsi: params.deskripsi,
      jumlah: params.jumlah,
      tanggal: params.tanggal,
      kategoriId: params.kategoriId,
      catatan: params.catatan,
    );
  }
}

class TambahPengeluaranParams extends Equatable {
  final String deskripsi;
  final double jumlah;
  final DateTime tanggal;
  final String? kategoriId;
  final String? catatan;

  const TambahPengeluaranParams({
    required this.deskripsi,
    required this.jumlah,
    required this.tanggal,
    this.kategoriId,
    this.catatan,
  });

  @override
  List<Object?> get props => [deskripsi, jumlah, tanggal, kategoriId, catatan];
}
