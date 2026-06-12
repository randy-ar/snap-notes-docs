import 'package:dartz/dartz.dart';
import 'package:snap_notes/core/error/failures.dart';
import 'package:snap_notes/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:snap_notes/features/dashboard/domain/entities/ringkasan.dart';
import 'package:snap_notes/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:dio/dio.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;

  DashboardRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, RingkasanDashboard>> getRingkasan({int? bulan, int? tahun}) async {
    try {
      final ringkasan = await remoteDataSource.getRingkasan(bulan: bulan, tahun: tahun);
      return Right(ringkasan);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data?['message'] ?? e.message ?? 'Gagal memuat ringkasan dashboard'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
