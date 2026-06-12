import 'package:dartz/dartz.dart';
import 'package:snap_notes/core/error/failures.dart';
import 'package:snap_notes/core/usecase/usecase.dart';
import 'package:snap_notes/features/receipt/domain/entities/receipt_entity.dart';
import 'package:snap_notes/features/receipt/domain/repositories/receipt_repository.dart';

class GetReceiptDetailUseCase implements UseCase<ReceiptEntity, String> {
  final ReceiptRepository repository;

  GetReceiptDetailUseCase(this.repository);

  @override
  Future<Either<Failure, ReceiptEntity>> call(String id) async {
    return await repository.getReceiptDetail(id);
  }
}
