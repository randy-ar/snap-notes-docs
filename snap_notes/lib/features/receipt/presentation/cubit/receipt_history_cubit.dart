import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snap_notes/features/receipt/domain/usecases/get_receipts_usecase.dart';
import 'package:snap_notes/features/receipt/presentation/cubit/receipt_history_state.dart';

class ReceiptHistoryCubit extends Cubit<ReceiptHistoryState> {
  final GetReceiptsUseCase getReceiptsUseCase;

  ReceiptHistoryCubit({required this.getReceiptsUseCase}) : super(ReceiptHistoryInitial());

  Future<void> fetchReceipts({required String month, required String year}) async {
    emit(ReceiptHistoryLoading());
    final result = await getReceiptsUseCase(GetReceiptsParams(month: month, year: year));
    
    result.fold(
      (failure) => emit(ReceiptHistoryError(failure.message)),
      (receipts) => emit(ReceiptHistoryLoaded(receipts, month, year)),
    );
  }
}
