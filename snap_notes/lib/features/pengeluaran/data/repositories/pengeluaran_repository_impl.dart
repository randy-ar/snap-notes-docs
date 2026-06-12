import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:snap_notes/core/error/exceptions.dart';
import 'package:snap_notes/core/error/failures.dart';
import 'package:snap_notes/features/pengeluaran/data/datasources/pengeluaran_remote_data_source.dart';
import 'package:snap_notes/features/pengeluaran/domain/entities/pengeluaran.dart';
import 'package:snap_notes/features/pengeluaran/domain/repositories/pengeluaran_repository.dart';

class PengeluaranRepositoryImpl implements PengeluaranRepository {
  final PengeluaranRemoteDataSource remoteDataSource;

  PengeluaranRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Pengeluaran>> tambahPengeluaran({
    required String deskripsi,
    required double jumlah,
    required DateTime tanggal,
    String? kategoriId,
    String? catatan,
  }) async {
    try {
      final pengeluaran = await remoteDataSource.tambahPengeluaran(
        deskripsi: deskripsi,
        jumlah: jumlah,
        tanggal: tanggal,
        kategoriId: kategoriId,
        catatan: catatan,
      );
      return Right(pengeluaran);
    } on DioException catch (e, stackTrace) {
      debugPrint('DioException in tambahPengeluaran: $e\n$stackTrace');
      if (e.response != null) {
        debugPrint('Response data: ${e.response?.data}');
        return Left(ServerFailure(e.response?.data['message'] ?? 'Terjadi kesalahan pada server'));
      }
      return const Left(ServerFailure('Tidak dapat terhubung ke server'));
    } on ServerException catch (e, stackTrace) {
      debugPrint('ServerException in tambahPengeluaran: $e\n$stackTrace');
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      debugPrint('Unknown Exception in tambahPengeluaran: $e\n$stackTrace');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Pengeluaran>>> getDaftarPengeluaran({
    int? bulan,
    int? tahun,
  }) async {
    try {
      final list = await remoteDataSource.getDaftarPengeluaran(
        bulan: bulan,
        tahun: tahun,
      );
      return Right(list);
    } on DioException catch (e, stackTrace) {
      debugPrint('DioException in getDaftarPengeluaran: $e\n$stackTrace');
      if (e.response != null) {
        return Left(ServerFailure(e.response?.data['message'] ?? 'Terjadi kesalahan pada server'));
      }
      return const Left(ServerFailure('Tidak dapat terhubung ke server'));
    } on ServerException catch (e, stackTrace) {
      debugPrint('ServerException in getDaftarPengeluaran: $e\n$stackTrace');
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      debugPrint('Unknown Exception in getDaftarPengeluaran: $e\n$stackTrace');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Pengeluaran>> getPengeluaranDetail(String id) async {
    try {
      final pengeluaran = await remoteDataSource.getPengeluaranDetail(id);
      return Right(pengeluaran);
    } on DioException catch (e, stackTrace) {
      debugPrint('DioException in getPengeluaranDetail: $e\n$stackTrace');
      if (e.response != null) {
        return Left(ServerFailure(e.response?.data['message'] ?? 'Terjadi kesalahan pada server'));
      }
      return const Left(ServerFailure('Tidak dapat terhubung ke server'));
    } on ServerException catch (e, stackTrace) {
      debugPrint('ServerException in getPengeluaranDetail: $e\n$stackTrace');
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      debugPrint('Unknown Exception in getPengeluaranDetail: $e\n$stackTrace');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Pengeluaran>> updatePengeluaran(
    String id, {
    String? deskripsi,
    double? jumlah,
    DateTime? tanggal,
    String? kategoriId,
    String? catatan,
  }) async {
    try {
      final pengeluaran = await remoteDataSource.updatePengeluaran(
        id,
        deskripsi: deskripsi,
        jumlah: jumlah,
        tanggal: tanggal,
        kategoriId: kategoriId,
        catatan: catatan,
      );
      return Right(pengeluaran);
    } on DioException catch (e, stackTrace) {
      debugPrint('DioException in updatePengeluaran: $e\n$stackTrace');
      if (e.response != null) {
        return Left(ServerFailure(e.response?.data['message'] ?? 'Terjadi kesalahan pada server'));
      }
      return const Left(ServerFailure('Tidak dapat terhubung ke server'));
    } on ServerException catch (e, stackTrace) {
      debugPrint('ServerException in updatePengeluaran: $e\n$stackTrace');
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      debugPrint('Unknown Exception in updatePengeluaran: $e\n$stackTrace');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> hapusPengeluaran(String id) async {
    try {
      await remoteDataSource.hapusPengeluaran(id);
      return const Right(null);
    } on DioException catch (e, stackTrace) {
      debugPrint('DioException in hapusPengeluaran: $e\n$stackTrace');
      if (e.response != null) {
        return Left(ServerFailure(e.response?.data['message'] ?? 'Terjadi kesalahan pada server'));
      }
      return const Left(ServerFailure('Tidak dapat terhubung ke server'));
    } on ServerException catch (e, stackTrace) {
      debugPrint('ServerException in hapusPengeluaran: $e\n$stackTrace');
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      debugPrint('Unknown Exception in hapusPengeluaran: $e\n$stackTrace');
      return Left(ServerFailure(e.toString()));
    }
  }
}
