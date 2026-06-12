import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:snap_notes/core/error/failures.dart';
import 'package:snap_notes/core/usecase/usecase.dart';
import 'package:snap_notes/features/receipt/domain/entities/receipt_entity.dart';
import 'package:snap_notes/features/receipt/domain/repositories/receipt_repository.dart';

class ScanReceiptUseCase implements UseCase<ReceiptEntity, ScanReceiptParams> {
  final ReceiptRepository repository;

  ScanReceiptUseCase(this.repository);

  @override
  Future<Either<Failure, ReceiptEntity>> call(ScanReceiptParams params) async {
    return await repository.scanReceipt(params.image);
  }
}

class ScanReceiptParams {
  final File image;

  ScanReceiptParams({required this.image});
}
