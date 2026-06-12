import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:snap_notes/core/error/failures.dart';
import 'package:snap_notes/features/receipt/domain/entities/receipt_entity.dart';

abstract class ReceiptRepository {
  Future<Either<Failure, ReceiptEntity>> scanReceipt(File image);
  Future<Either<Failure, List<ReceiptEntity>>> getReceipts({required String month, required String year});
  Future<Either<Failure, ReceiptEntity>> getReceiptDetail(String id);
}
