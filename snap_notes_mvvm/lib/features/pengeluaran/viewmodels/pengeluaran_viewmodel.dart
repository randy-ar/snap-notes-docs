import 'package:flutter/foundation.dart';
import 'package:snap_notes_mvvm/features/pengeluaran/models/pengeluaran_service.dart';
import 'package:snap_notes_mvvm/features/pengeluaran/models/pengeluaran.dart';
import 'package:snap_notes_mvvm/features/pengeluaran/models/kategori.dart';

class PengeluaranViewModel extends ChangeNotifier {
  final PengeluaranService _pengeluaranService;

  PengeluaranViewModel({required this._pengeluaranService});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Pengeluaran> _pengeluaranList = [];
  List<Pengeluaran> get pengeluaranList => _pengeluaranList;

  int _currentPage = 1;
  int get currentPage => _currentPage;

  bool _hasMoreData = true;
  bool get hasMoreData => _hasMoreData;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  Map<String, dynamic>? _overviewData;
  Map<String, dynamic>? get overviewData => _overviewData;

  Pengeluaran? _pengeluaranDetail;
  Pengeluaran? get pengeluaranDetail => _pengeluaranDetail;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<Kategori> _categories = [];
  List<Kategori> get categories => _categories;

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

  Future<void> loadOverview({int? bulan, int? tahun}) async {
    try {
      final now = DateTime.now();
      _overviewData = await _pengeluaranService.getPengeluaranOverview(
        bulan: bulan ?? now.month,
        tahun: tahun ?? now.year,
      );
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadPengeluaran({bool isRefresh = false}) async {
    if (isRefresh) {
      _currentPage = 1;
      _hasMoreData = true;
      _pengeluaranList.clear();
      _setLoading(true);
    } else {
      if (!_hasMoreData || _isLoadingMore) return;
      _isLoadingMore = true;
      notifyListeners();
    }

    _errorMessage = null;

    try {
      final result = await _pengeluaranService.getDaftarPengeluaran(
        page: _currentPage,
        limit: 10,
      );
      final List<Pengeluaran> newData = result['data'] as List<Pengeluaran>;
      final meta = result['meta'] as Map<String, dynamic>;

      if (isRefresh) {
        _pengeluaranList = newData;
      } else {
        _pengeluaranList.addAll(newData);
      }

      _currentPage = (meta['page'] as int) + 1;
      _hasMoreData = (meta['page'] as int) < (meta['totalPages'] as int);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      if (isRefresh) {
        _setLoading(false);
      } else {
        _isLoadingMore = false;
        notifyListeners();
      }
    }
  }

  Future<void> loadMorePengeluaran() => loadPengeluaran(isRefresh: false);

  Future<void> loadCategories({String? jenis}) async {
    _errorMessage = null;
    try {
      final list = await _pengeluaranService.getDaftarKategori(jenis: jenis);
      _categories = list;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
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

  Future<void> reparseStruk(String strukId, String prompt) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _pengeluaranService.reparseStruk(strukId, prompt);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }
}

