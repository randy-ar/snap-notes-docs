import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:snap_notes/core/error/exceptions.dart';
import 'package:snap_notes/core/error/failures.dart';
import 'package:snap_notes/features/receipt/data/models/receipt_model.dart';
import 'package:snap_notes/features/receipt/domain/repositories/receipt_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:snap_notes/features/receipt/data/datasources/receipt_local_datasource.dart';
import 'package:snap_notes/features/receipt/data/datasources/receipt_remote_datasource.dart';

class ReceiptRepositoryImpl implements ReceiptRepository {
  final ReceiptLocalDataSource localDataSource;
  final ReceiptRemoteDataSource remoteDataSource;

  ReceiptRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, ReceiptModel>> scanReceipt(File image) async {
    try {
      final recognizedTextEntity = await localDataSource.extractTextFromImage(image);
      final receiptModel = await remoteDataSource.parseReceiptData(
        recognizedTextEntity.text,
        image,
        recognizedTextEntity.lines,
        recognizedTextEntity.imageWidth,
        recognizedTextEntity.imageHeight,
      );
      return Right(receiptModel);
    } on ServerException catch (e, stackTrace) {
      debugPrint('ServerException in scanReceipt: $e\n$stackTrace');
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      debugPrint('Unknown Exception in scanReceipt: $e\n$stackTrace');
      return Left(LocalFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ReceiptModel>>> getReceipts({required String month, required String year}) async {
    try {
      final receipts = await remoteDataSource.getReceipts(month, year);
      return Right(receipts);
    } on ServerException catch (e, stackTrace) {
      debugPrint('ServerException in getReceipts: $e\n$stackTrace');
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      debugPrint('Unknown Exception in getReceipts: $e\n$stackTrace');
      return Left(LocalFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ReceiptModel>> getReceiptDetail(String id) async {
    try {
      final receipt = await remoteDataSource.getReceiptDetail(id);
      return Right(receipt);
    } on ServerException catch (e, stackTrace) {
      debugPrint('ServerException in getReceiptDetail: $e\n$stackTrace');
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      debugPrint('Unknown Exception in getReceiptDetail: $e\n$stackTrace');
      return Left(LocalFailure(e.toString()));
    }
  }
}
