import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/preferensi_notifikasi.dart';
import '../../domain/usecases/tambah_preferensi.dart';
import '../../domain/usecases/update_preferensi.dart';
import 'notifikasi_form_state.dart';

class NotifikasiFormCubit extends Cubit<NotifikasiFormState> {
  final TambahPreferensi tambahPreferensi;
  final UpdatePreferensi updatePreferensi;

  NotifikasiFormCubit({
    required this.tambahPreferensi,
    required this.updatePreferensi,
  }) : super(NotifikasiFormInitial());

  Future<void> simpanPreferensi(PreferensiNotifikasi preferensi) async {
    emit(NotifikasiFormLoading());

    final isEdit = preferensi.id != null;
    
    final result = isEdit 
        ? await updatePreferensi(preferensi.id!, preferensi)
        : await tambahPreferensi(preferensi);

    result.fold(
      (failure) => emit(NotifikasiFormError(failure.message)),
      (_) => emit(NotifikasiFormSuccess(
        isEdit ? "Jadwal berhasil diperbarui" : "Jadwal berhasil ditambahkan"
      )),
    );
  }
}
