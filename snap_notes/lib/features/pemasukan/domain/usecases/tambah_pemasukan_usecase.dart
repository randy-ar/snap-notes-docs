import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:snap_notes/core/error/failures.dart';
import 'package:snap_notes/core/usecase/usecase.dart';
import 'package:snap_notes/features/pemasukan/domain/entities/pemasukan.dart';
import 'package:snap_notes/features/pemasukan/domain/repositories/pemasukan_repository.dart';

class TambahPemasukanUseCase implements UseCase<Pemasukan, TambahPemasukanParams> {
  final PemasukanRepository repository;

  TambahPemasukanUseCase(this.repository);

  @override
  Future<Either<Failure, Pemasukan>> call(TambahPemasukanParams params) async {
    return await repository.tambahPemasukan(
      deskripsi: params.deskripsi,
      jumlah: params.jumlah,
      tanggal: params.tanggal,
      kategoriId: params.kategoriId,
      catatan: params.catatan,
    );
  }
}

class TambahPemasukanParams extends Equatable {
  final String deskripsi;
  final double jumlah;
  final DateTime tanggal;
  final String? kategoriId;
  final String? catatan;

  const TambahPemasukanParams({
    required this.deskripsi,
    required this.jumlah,
    required this.tanggal,
    this.kategoriId,
    this.catatan,
  });

  @override
  List<Object?> get props => [deskripsi, jumlah, tanggal, kategoriId, catatan];
}
