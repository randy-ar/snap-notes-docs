import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:snap_notes/core/error/exceptions.dart';
import 'package:snap_notes/core/error/failures.dart';
import 'package:snap_notes/features/pemasukan/data/datasources/pemasukan_remote_data_source.dart';
import 'package:snap_notes/features/pemasukan/domain/entities/pemasukan.dart';
import 'package:snap_notes/features/pemasukan/domain/repositories/pemasukan_repository.dart';

class PemasukanRepositoryImpl implements PemasukanRepository {
  final PemasukanRemoteDataSource remoteDataSource;

  PemasukanRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Pemasukan>> tambahPemasukan({
    required String deskripsi,
    required double jumlah,
    required DateTime tanggal,
    String? kategoriId,
    String? catatan,
  }) async {
    try {
      final pemasukan = await remoteDataSource.tambahPemasukan(
        deskripsi: deskripsi,
        jumlah: jumlah,
        tanggal: tanggal,
        kategoriId: kategoriId,
        catatan: catatan,
      );
      return Right(pemasukan);
    } on DioException catch (e, stackTrace) {
      debugPrint('DioException in tambahPemasukan: $e\n$stackTrace');
      if (e.response != null) {
        debugPrint('Response data: ${e.response?.data}');
        return Left(ServerFailure(e.response?.data['message'] ?? 'Terjadi kesalahan pada server'));
      }
      return const Left(ServerFailure('Tidak dapat terhubung ke server'));
    } on ServerException catch (e, stackTrace) {
      debugPrint('ServerException in tambahPemasukan: $e\n$stackTrace');
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      debugPrint('Unknown Exception in tambahPemasukan: $e\n$stackTrace');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Pemasukan>>> getDaftarPemasukan({
    int? bulan,
    int? tahun,
  }) async {
    try {
      final list = await remoteDataSource.getDaftarPemasukan(
        bulan: bulan,
        tahun: tahun,
      );
      return Right(list);
    } on DioException catch (e, stackTrace) {
      debugPrint('DioException in getDaftarPemasukan: $e\n$stackTrace');
      if (e.response != null) {
        return Left(ServerFailure(e.response?.data['message'] ?? 'Terjadi kesalahan pada server'));
      }
      return const Left(ServerFailure('Tidak dapat terhubung ke server'));
    } on ServerException catch (e, stackTrace) {
      debugPrint('ServerException in getDaftarPemasukan: $e\n$stackTrace');
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      debugPrint('Unknown Exception in getDaftarPemasukan: $e\n$stackTrace');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Pemasukan>> getPemasukanDetail(String id) async {
    try {
      final pemasukan = await remoteDataSource.getPemasukanDetail(id);
      return Right(pemasukan);
    } on DioException catch (e, stackTrace) {
      debugPrint('DioException in getPemasukanDetail: $e\n$stackTrace');
      if (e.response != null) {
        return Left(ServerFailure(e.response?.data['message'] ?? 'Terjadi kesalahan pada server'));
      }
      return const Left(ServerFailure('Tidak dapat terhubung ke server'));
    } on ServerException catch (e, stackTrace) {
      debugPrint('ServerException in getPemasukanDetail: $e\n$stackTrace');
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      debugPrint('Unknown Exception in getPemasukanDetail: $e\n$stackTrace');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Pemasukan>> updatePemasukan(
    String id, {
    String? deskripsi,
    double? jumlah,
    DateTime? tanggal,
    String? kategoriId,
    String? catatan,
  }) async {
    try {
      final pemasukan = await remoteDataSource.updatePemasukan(
        id,
        deskripsi: deskripsi,
        jumlah: jumlah,
        tanggal: tanggal,
        kategoriId: kategoriId,
        catatan: catatan,
      );
      return Right(pemasukan);
    } on DioException catch (e, stackTrace) {
      debugPrint('DioException in updatePemasukan: $e\n$stackTrace');
      if (e.response != null) {
        return Left(ServerFailure(e.response?.data['message'] ?? 'Terjadi kesalahan pada server'));
      }
      return const Left(ServerFailure('Tidak dapat terhubung ke server'));
    } on ServerException catch (e, stackTrace) {
      debugPrint('ServerException in updatePemasukan: $e\n$stackTrace');
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      debugPrint('Unknown Exception in updatePemasukan: $e\n$stackTrace');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> hapusPemasukan(String id) async {
    try {
      await remoteDataSource.hapusPemasukan(id);
      return const Right(null);
    } on DioException catch (e, stackTrace) {
      debugPrint('DioException in hapusPemasukan: $e\n$stackTrace');
      if (e.response != null) {
        return Left(ServerFailure(e.response?.data['message'] ?? 'Terjadi kesalahan pada server'));
      }
      return const Left(ServerFailure('Tidak dapat terhubung ke server'));
    } on ServerException catch (e, stackTrace) {
      debugPrint('ServerException in hapusPemasukan: $e\n$stackTrace');
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      debugPrint('Unknown Exception in hapusPemasukan: $e\n$stackTrace');
      return Left(ServerFailure(e.toString()));
    }
  }
}
