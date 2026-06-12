import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snap_notes/features/pengeluaran/domain/usecases/tambah_pengeluaran_usecase.dart';
import 'package:snap_notes/features/pengeluaran/domain/usecases/update_pengeluaran_usecase.dart';
import 'package:snap_notes/features/pengeluaran/presentation/cubit/pengeluaran_form_state.dart';

class PengeluaranFormCubit extends Cubit<PengeluaranFormState> {
  final TambahPengeluaranUseCase tambahPengeluaranUseCase;
  final UpdatePengeluaranUseCase updatePengeluaranUseCase;

  PengeluaranFormCubit({
    required this.tambahPengeluaranUseCase,
    required this.updatePengeluaranUseCase,
  }) : super(PengeluaranFormInitial());

  Future<void> simpanPengeluaran({
    String? id,
    required String deskripsi,
    required double jumlah,
    required DateTime tanggal,
    String? kategoriId,
    String? catatan,
  }) async {
    emit(PengeluaranFormLoading());

    if (id == null) {
      final result = await tambahPengeluaranUseCase(TambahPengeluaranParams(
        deskripsi: deskripsi,
        jumlah: jumlah,
        tanggal: tanggal,
        kategoriId: kategoriId,
        catatan: catatan,
      ));

      result.fold(
        (failure) {
          debugPrint('TambahPengeluaran Error: ${failure.message}');
          emit(PengeluaranFormError(failure.message));
        },
        (pengeluaran) => emit(PengeluaranFormSuccess(pengeluaran)),
      );
    } else {
      final result = await updatePengeluaranUseCase(
        id,
        deskripsi: deskripsi,
        jumlah: jumlah,
        tanggal: tanggal,
        kategoriId: kategoriId,
        catatan: catatan,
      );

      result.fold(
        (failure) {
          debugPrint('UpdatePengeluaran Error: ${failure.message}');
          emit(PengeluaranFormError(failure.message));
        },
        (pengeluaran) => emit(PengeluaranFormSuccess(pengeluaran)),
      );
    }
  }
}
