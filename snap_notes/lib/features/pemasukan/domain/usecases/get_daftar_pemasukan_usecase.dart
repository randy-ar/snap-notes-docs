import 'package:dartz/dartz.dart';
import 'package:snap_notes/core/error/failures.dart';
import 'package:snap_notes/features/pemasukan/domain/entities/pemasukan.dart';
import 'package:snap_notes/features/pemasukan/domain/repositories/pemasukan_repository.dart';

class GetDaftarPemasukanUseCase {
  final PemasukanRepository repository;

  GetDaftarPemasukanUseCase(this.repository);

  Future<Either<Failure, List<Pemasukan>>> call({int? bulan, int? tahun}) async {
    return await repository.getDaftarPemasukan(bulan: bulan, tahun: tahun);
  }
}
