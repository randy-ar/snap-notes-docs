import 'package:dartz/dartz.dart';
import 'package:snap_notes/core/error/failures.dart';
import 'package:snap_notes/features/pemasukan/domain/entities/pemasukan.dart';
import 'package:snap_notes/features/pemasukan/domain/repositories/pemasukan_repository.dart';

class GetPemasukanDetailUseCase {
  final PemasukanRepository repository;

  GetPemasukanDetailUseCase(this.repository);

  Future<Either<Failure, Pemasukan>> call(String id) async {
    return await repository.getPemasukanDetail(id);
  }
}
