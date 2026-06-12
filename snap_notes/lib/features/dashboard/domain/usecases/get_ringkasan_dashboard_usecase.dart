import 'package:dartz/dartz.dart';
import 'package:snap_notes/core/error/failures.dart';
import 'package:snap_notes/features/dashboard/domain/entities/ringkasan.dart';
import 'package:snap_notes/features/dashboard/domain/repositories/dashboard_repository.dart';

class GetRingkasanDashboardUseCase {
  final DashboardRepository repository;

  GetRingkasanDashboardUseCase(this.repository);

  Future<Either<Failure, RingkasanDashboard>> call({int? bulan, int? tahun}) {
    return repository.getRingkasan(bulan: bulan, tahun: tahun);
  }
}
