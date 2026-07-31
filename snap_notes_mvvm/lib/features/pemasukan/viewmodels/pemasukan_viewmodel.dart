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

  int _currentPage = 1;
  int get currentPage => _currentPage;

  bool _hasMoreData = true;
  bool get hasMoreData => _hasMoreData;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  Map<String, dynamic>? _overviewData;
  Map<String, dynamic>? get overviewData => _overviewData;

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

  Future<void> loadOverview({int? bulan, int? tahun}) async {
    try {
      final now = DateTime.now();
      _overviewData = await _pemasukanService.getPemasukanOverview(
        bulan: bulan ?? now.month,
        tahun: tahun ?? now.year,
      );
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadPemasukan({bool isRefresh = false}) async {
    if (isRefresh) {
      _currentPage = 1;
      _hasMoreData = true;
      _pemasukanList.clear();
      _setLoading(true);
    } else {
      if (!_hasMoreData || _isLoadingMore) return;
      _isLoadingMore = true;
      notifyListeners();
    }

    _errorMessage = null;

    try {
      final result = await _pemasukanService.getDaftarPemasukan(
        page: _currentPage,
        limit: 10,
      );
      final List<Pemasukan> newData = result['data'] as List<Pemasukan>;
      final meta = result['meta'] as Map<String, dynamic>;

      if (isRefresh) {
        _pemasukanList = newData;
      } else {
        _pemasukanList.addAll(newData);
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

  Future<void> loadMorePemasukan() => loadPemasukan(isRefresh: false);

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

  Future<void> submitPemasukan({
    String? id,
    String? deskripsi,
    double? jumlah,
    DateTime? tanggal,
    String? kategoriId,
    String? catatan,
    bool isDelete = false,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      if (isDelete && id != null) {
        await _pemasukanService.deletePemasukan(id);
        _pemasukanList.removeWhere((p) => p.id == id);
      } else if (id == null && deskripsi != null && jumlah != null && tanggal != null) {
        final pemasukan = await _pemasukanService.createPemasukan(
          deskripsi: deskripsi,
          jumlah: jumlah,
          tanggal: tanggal,
          kategoriId: kategoriId,
          catatan: catatan,
        );
        _pemasukanList.insert(0, pemasukan);
      } else if (id != null) {
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
      }
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
