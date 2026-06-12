import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/preferensi_notifikasi.dart';
import '../../domain/usecases/get_preferensi_list.dart';
import '../../domain/usecases/hapus_preferensi.dart';
import '../../domain/usecases/update_preferensi.dart';
import 'notifikasi_list_state.dart';

class NotifikasiListCubit extends Cubit<NotifikasiListState> {
  final GetPreferensiList getPreferensiList;
  final HapusPreferensi hapusPreferensi;
  final UpdatePreferensi updatePreferensi;

  NotifikasiListCubit({
    required this.getPreferensiList,
    required this.hapusPreferensi,
    required this.updatePreferensi,
  }) : super(NotifikasiListInitial());

  Future<void> fetchPreferensiList() async {
    emit(NotifikasiListLoading());
    final result = await getPreferensiList();
    result.fold(
      (failure) => emit(NotifikasiListError(failure.message)),
      (list) => emit(NotifikasiListLoaded(list)),
    );
  }

  Future<void> toggleAktif(PreferensiNotifikasi preferensi, bool aktif) async {
    if (preferensi.id == null) return;
    
    // We can show loading if we want, or do it optimistically.
    // We'll show loading for now.
    emit(NotifikasiListLoading());
    
    final updatedPreferensi = PreferensiNotifikasi(
      id: preferensi.id,
      hariAktif: preferensi.hariAktif,
      jamNotifikasi: preferensi.jamNotifikasi,
      aktif: aktif,
    );

    final result = await updatePreferensi(preferensi.id!, updatedPreferensi);
    
    result.fold(
      (failure) => emit(NotifikasiListError(failure.message)),
      (_) {
        emit(const NotifikasiListActionSuccess("Status notifikasi berhasil diperbarui"));
        fetchPreferensiList(); // refetch
      },
    );
  }

  Future<void> deletePreferensi(String id) async {
    emit(NotifikasiListLoading());
    final result = await hapusPreferensi(id);
    result.fold(
      (failure) => emit(NotifikasiListError(failure.message)),
      (_) {
        emit(const NotifikasiListActionSuccess("Jadwal notifikasi berhasil dihapus"));
        fetchPreferensiList();
      },
    );
  }
}
