import 'package:dartz/dartz.dart';
import 'package:snap_notes/core/error/failures.dart';
import 'package:snap_notes/features/dashboard/domain/entities/ringkasan.dart';

abstract class DashboardRepository {
  Future<Either<Failure, RingkasanDashboard>> getRingkasan({int? bulan, int? tahun});
}
