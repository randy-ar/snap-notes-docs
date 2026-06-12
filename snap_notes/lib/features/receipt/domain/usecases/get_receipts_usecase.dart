import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:snap_notes/core/error/failures.dart';
import 'package:snap_notes/core/usecase/usecase.dart';
import 'package:snap_notes/features/receipt/domain/entities/receipt_entity.dart';
import 'package:snap_notes/features/receipt/domain/repositories/receipt_repository.dart';

class GetReceiptsUseCase implements UseCase<List<ReceiptEntity>, GetReceiptsParams> {
  final ReceiptRepository repository;

  GetReceiptsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ReceiptEntity>>> call(GetReceiptsParams params) async {
    return await repository.getReceipts(month: params.month, year: params.year);
  }
}

class GetReceiptsParams extends Equatable {
  final String month;
  final String year;

  const GetReceiptsParams({required this.month, required this.year});

  @override
  List<Object?> get props => [month, year];
}
