import 'package:equatable/equatable.dart';
import 'package:snap_notes/features/receipt/domain/entities/receipt_entity.dart';

abstract class ReceiptDetailState extends Equatable {
  const ReceiptDetailState();

  @override
  List<Object> get props => [];
}

class ReceiptDetailInitial extends ReceiptDetailState {}

class ReceiptDetailLoading extends ReceiptDetailState {}

class ReceiptDetailLoaded extends ReceiptDetailState {
  final ReceiptEntity receipt;

  const ReceiptDetailLoaded(this.receipt);

  @override
  List<Object> get props => [receipt];
}

class ReceiptDetailError extends ReceiptDetailState {
  final String message;

  const ReceiptDetailError(this.message);

  @override
  List<Object> get props => [message];
}
