import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../datasources/local_notification_data_source.dart';
import '../datasources/notifikasi_remote_data_source.dart';
import '../../domain/entities/preferensi_notifikasi.dart';
import '../models/preferensi_notifikasi_model.dart';
import '../../domain/repositories/notifikasi_repository.dart';

class NotifikasiRepositoryImpl implements NotifikasiRepository {
  final NotifikasiRemoteDataSource remoteDataSource;
  final LocalNotificationDataSource localDataSource;

  NotifikasiRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<PreferensiNotifikasi>>> getPreferensiList() async {
    try {
      final remoteData = await remoteDataSource.getPreferensiList();
      await localDataSource.scheduleNotifications(remoteData);
      return Right(remoteData);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PreferensiNotifikasi>> tambahPreferensi(PreferensiNotifikasi preferensi) async {
    try {
      final modelToSave = PreferensiNotifikasiModel.fromEntity(preferensi);
      final model = await remoteDataSource.createPreferensi(modelToSave);
      await _syncLocalNotifications();
      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PreferensiNotifikasi>> updatePreferensi(String id, PreferensiNotifikasi preferensi) async {
    try {
      final modelToSave = PreferensiNotifikasiModel.fromEntity(preferensi);
      final model = await remoteDataSource.updatePreferensi(id, modelToSave);
      await _syncLocalNotifications();
      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> hapusPreferensi(String id) async {
    try {
      await remoteDataSource.deletePreferensi(id);
      await _syncLocalNotifications();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<void> _syncLocalNotifications() async {
    try {
      final remoteData = await remoteDataSource.getPreferensiList();
      await localDataSource.scheduleNotifications(remoteData);
    } catch (_) {
      // Ignore if sync fails, it will sync on next get
    }
  }
}
