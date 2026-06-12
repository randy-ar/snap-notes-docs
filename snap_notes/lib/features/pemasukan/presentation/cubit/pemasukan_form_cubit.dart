import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snap_notes/features/pemasukan/domain/usecases/tambah_pemasukan_usecase.dart';
import 'package:snap_notes/features/pemasukan/domain/usecases/update_pemasukan_usecase.dart';
import 'package:snap_notes/features/pemasukan/presentation/cubit/pemasukan_form_state.dart';

class PemasukanFormCubit extends Cubit<PemasukanFormState> {
  final TambahPemasukanUseCase tambahPemasukanUseCase;
  final UpdatePemasukanUseCase updatePemasukanUseCase;

  PemasukanFormCubit({
    required this.tambahPemasukanUseCase,
    required this.updatePemasukanUseCase,
  }) : super(PemasukanFormInitial());

  Future<void> simpanPemasukan({
    String? id,
    required String deskripsi,
    required double jumlah,
    required DateTime tanggal,
    String? kategoriId,
    String? catatan,
  }) async {
    emit(PemasukanFormLoading());

    if (id == null) {
      final result = await tambahPemasukanUseCase(TambahPemasukanParams(
        deskripsi: deskripsi,
        jumlah: jumlah,
        tanggal: tanggal,
        kategoriId: kategoriId,
        catatan: catatan,
      ));

      result.fold(
        (failure) {
          debugPrint('TambahPemasukan Error: ${failure.message}');
          emit(PemasukanFormError(failure.message));
        },
        (pemasukan) => emit(PemasukanFormSuccess(pemasukan)),
      );
    } else {
      final result = await updatePemasukanUseCase(
        id,
        deskripsi: deskripsi,
        jumlah: jumlah,
        tanggal: tanggal,
        kategoriId: kategoriId,
        catatan: catatan,
      );

      result.fold(
        (failure) {
          debugPrint('UpdatePemasukan Error: ${failure.message}');
          emit(PemasukanFormError(failure.message));
        },
        (pemasukan) => emit(PemasukanFormSuccess(pemasukan)),
      );
    }
  }
}
