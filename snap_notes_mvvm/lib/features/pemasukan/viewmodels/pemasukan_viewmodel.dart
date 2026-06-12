import 'package:flutter/foundation.dart';
import 'package:snap_notes_mvvm/features/pemasukan/models/pemasukan_service.dart';
import 'package:snap_notes_mvvm/features/pemasukan/models/pemasukan.dart';

class PemasukanViewModel extends ChangeNotifier {
  final PemasukanService _pemasukanService;

  PemasukanViewModel({required this._pemasukanService});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Pemasukan> _pemasukanList = [];
  List<Pemasukan> get pemasukanList => _pemasukanList;

  Pemasukan? _pemasukanDetail;
  Pemasukan? get pemasukanDetail => _pemasukanDetail;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> loadPemasukan({int? bulan, int? tahun}) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final list = await _pemasukanService.getDaftarPemasukan(
        bulan: bulan,
        tahun: tahun,
      );
      _pemasukanList = list;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
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
