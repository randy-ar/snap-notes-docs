import 'package:equatable/equatable.dart';
import 'package:snap_notes/features/receipt/domain/entities/receipt_entity.dart';

abstract class ReceiptHistoryState extends Equatable {
  const ReceiptHistoryState();

  @override
  List<Object> get props => [];
}

class ReceiptHistoryInitial extends ReceiptHistoryState {}

class ReceiptHistoryLoading extends ReceiptHistoryState {}

class ReceiptHistoryLoaded extends ReceiptHistoryState {
  final List<ReceiptEntity> receipts;
  final String month;
  final String year;

  const ReceiptHistoryLoaded(this.receipts, this.month, this.year);

  @override
  List<Object> get props => [receipts, month, year];
}

class ReceiptHistoryError extends ReceiptHistoryState {
  final String message;

  const ReceiptHistoryError(this.message);

  @override
  List<Object> get props => [message];
}
