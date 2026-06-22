import 'package:flutter/foundation.dart';
import 'package:snap_notes_mvvm/features/pengeluaran/models/pengeluaran_service.dart';
import 'package:snap_notes_mvvm/features/pengeluaran/models/pengeluaran.dart';

class PengeluaranViewModel extends ChangeNotifier {
  final PengeluaranService _pengeluaranService;

  PengeluaranViewModel({required this._pengeluaranService});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Pengeluaran> _pengeluaranList = [];
  List<Pengeluaran> get pengeluaranList => _pengeluaranList;

  Pengeluaran? _pengeluaranDetail;
  Pengeluaran? get pengeluaranDetail => _pengeluaranDetail;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> loadPengeluaranDetail(String id) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final detail = await _pengeluaranService.getPengeluaranDetail(id);
      _pengeluaranDetail = detail;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  double _totalCurrentMonth = 0;
  double get totalCurrentMonth => _totalCurrentMonth;

  double _totalPreviousMonth = 0;
  double get totalPreviousMonth => _totalPreviousMonth;

  double get percentageChange {
    if (_totalPreviousMonth == 0) {
      if (_totalCurrentMonth == 0) return 0.0;
      return 100.0;
    }
    return ((_totalCurrentMonth - _totalPreviousMonth) / _totalPreviousMonth) * 100;
  }

  Future<void> loadPengeluaran({int? bulan, int? tahun}) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final now = DateTime.now();
      final targetBulan = bulan ?? now.month;
      final targetTahun = tahun ?? now.year;

      final list = await _pengeluaranService.getDaftarPengeluaran(
        bulan: targetBulan,
        tahun: targetTahun,
      );
      _pengeluaranList = list;
      _totalCurrentMonth = _pengeluaranList.fold(0, (sum, item) => sum + item.jumlah);

      int prevBulan = targetBulan - 1;
      int prevTahun = targetTahun;
      if (prevBulan == 0) {
        prevBulan = 12;
        prevTahun -= 1;
      }
      final prevList = await _pengeluaranService.getDaftarPengeluaran(
        bulan: prevBulan,
        tahun: prevTahun,
      );
      _totalPreviousMonth = prevList.fold(0, (sum, item) => sum + item.jumlah);

    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> tambahPengeluaran({
    required String deskripsi,
    required double jumlah,
    required DateTime tanggal,
    String? kategoriId,
    String? catatan,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final pengeluaran = await _pengeluaranService.tambahPengeluaran(
        deskripsi: deskripsi,
        jumlah: jumlah,
        tanggal: tanggal,
        kategoriId: kategoriId,
        catatan: catatan,
      );
      _pengeluaranList.insert(0, pengeluaran);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updatePengeluaran(
    String id, {
    String? deskripsi,
    double? jumlah,
    DateTime? tanggal,
    String? kategoriId,
    String? catatan,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final pengeluaran = await _pengeluaranService.updatePengeluaran(
        id,
        deskripsi: deskripsi,
        jumlah: jumlah,
        tanggal: tanggal,
        kategoriId: kategoriId,
        catatan: catatan,
      );
      final index = _pengeluaranList.indexWhere((p) => p.id == id);
      if (index != -1) {
        _pengeluaranList[index] = pengeluaran;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> hapusPengeluaran(String id) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _pengeluaranService.hapusPengeluaran(id);
      _pengeluaranList.removeWhere((p) => p.id == id);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }
}
