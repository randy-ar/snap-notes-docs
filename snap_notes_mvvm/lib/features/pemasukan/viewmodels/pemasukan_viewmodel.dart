import 'package:flutter/foundation.dart';
import 'package:snap_notes_mvvm/features/pemasukan/models/pemasukan_service.dart';
import 'package:snap_notes_mvvm/features/pemasukan/models/pemasukan.dart';
import 'package:snap_notes_mvvm/features/pengeluaran/models/kategori.dart';

class PemasukanViewModel extends ChangeNotifier {
  final PemasukanService _pemasukanService;
  bool _isDisposed = false;

  PemasukanViewModel({required this._pemasukanService});

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Pemasukan> _pemasukanList = [];
  List<Pemasukan> get pemasukanList => _pemasukanList;

  Pemasukan? _pemasukanDetail;
  Pemasukan? get pemasukanDetail => _pemasukanDetail;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<Kategori> _categories = [];
  List<Kategori> get categories => _categories;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
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

  Future<void> loadPemasukan({int? bulan, int? tahun}) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final now = DateTime.now();
      final targetBulan = bulan ?? now.month;
      final targetTahun = tahun ?? now.year;

      final list = await _pemasukanService.getDaftarPemasukan(
        bulan: targetBulan,
        tahun: targetTahun,
      );
      _pemasukanList = list;
      _totalCurrentMonth = _pemasukanList.fold(0, (sum, item) => sum + item.jumlah);

      int prevBulan = targetBulan - 1;
      int prevTahun = targetTahun;
      if (prevBulan == 0) {
        prevBulan = 12;
        prevTahun -= 1;
      }
      final prevList = await _pemasukanService.getDaftarPemasukan(
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

  Future<void> loadCategories({String? jenis}) async {
    _errorMessage = null;
    try {
      final list = await _pemasukanService.getDaftarKategori(jenis: jenis);
      _categories = list;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> tambahPemasukan({
    required String deskripsi,
    required double jumlah,
    required DateTime tanggal,
    String? kategoriId,
    String? catatan,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final pemasukan = await _pemasukanService.tambahPemasukan(
        deskripsi: deskripsi,
        jumlah: jumlah,
        tanggal: tanggal,
        kategoriId: kategoriId,
        catatan: catatan,
      );
      _pemasukanList.insert(0, pemasukan);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updatePemasukan(
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
      final pemasukan = await _pemasukanService.updatePemasukan(
        id,
        deskripsi: deskripsi,
        jumlah: jumlah,
        tanggal: tanggal,
        kategoriId: kategoriId,
        catatan: catatan,
      );
      final index = _pemasukanList.indexWhere((p) => p.id == id);
      if (index != -1) {
        _pemasukanList[index] = pemasukan;
      }
      if (_pemasukanDetail?.id == id) {
        _pemasukanDetail = pemasukan;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> hapusPemasukan(String id) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _pemasukanService.hapusPemasukan(id);
      _pemasukanList.removeWhere((p) => p.id == id);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> getPemasukanDetail(String id) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final pemasukan = await _pemasukanService.getPemasukanDetail(id);
      _pemasukanDetail = pemasukan;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }
}
