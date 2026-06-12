import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snap_notes/features/receipt/domain/usecases/get_receipt_detail_usecase.dart';
import 'package:snap_notes/features/receipt/presentation/cubit/receipt_detail_state.dart';

class ReceiptDetailCubit extends Cubit<ReceiptDetailState> {
  final GetReceiptDetailUseCase getReceiptDetailUseCase;

  ReceiptDetailCubit({required this.getReceiptDetailUseCase}) : super(ReceiptDetailInitial());

  Future<void> fetchReceiptDetail(String id) async {
    emit(ReceiptDetailLoading());
    final result = await getReceiptDetailUseCase(id);
    
    result.fold(
      (failure) => emit(ReceiptDetailError(failure.message)),
      (receipt) => emit(ReceiptDetailLoaded(receipt)),
    );
  }
}
