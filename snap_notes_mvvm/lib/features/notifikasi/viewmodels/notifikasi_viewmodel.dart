import 'package:flutter/foundation.dart';
import 'package:snap_notes_mvvm/features/notifikasi/models/notifikasi_service.dart';
import 'package:snap_notes_mvvm/features/notifikasi/models/preferensi_notifikasi.dart';

class NotifikasiViewModel extends ChangeNotifier {
  final NotifikasiService _notifikasiService;

  NotifikasiViewModel({required this._notifikasiService});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<PreferensiNotifikasi> _preferensiList = [];
  List<PreferensiNotifikasi> get preferensiList => _preferensiList;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> init() async {
    await _notifikasiService.init();
  }

  Future<void> loadPreferensi() async {
    _errorMessage = null;
    
    // 1. Ambil data dari cache terlebih dahulu secara lokal
    final cachedList = await _notifikasiService.getCachedPreferensiList();
    if (cachedList.isNotEmpty) {
      _preferensiList = cachedList;
      notifyListeners();
    }

    // 2. Set loading hanya jika list masih kosong (agar skeleton muncul)
    if (_preferensiList.isEmpty) {
      _setLoading(true);
    }

    try {
      // 3. Ambil data terbaru dari server
      final list = await _notifikasiService.getPreferensiList();
      _preferensiList = list;
    } catch (e) {
      if (_preferensiList.isEmpty) {
        _errorMessage = e.toString();
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createPreferensi(PreferensiNotifikasi preferensi) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final result = await _notifikasiService.createPreferensi(preferensi);
      _preferensiList.add(result);
      await _notifikasiService.cachePreferensiList(_preferensiList);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updatePreferensi(String id, PreferensiNotifikasi preferensi) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final result = await _notifikasiService.updatePreferensi(id, preferensi);
      final index = _preferensiList.indexWhere((p) => p.id == id);
      if (index != -1) {
        _preferensiList[index] = result;
      }
      await _notifikasiService.cachePreferensiList(_preferensiList);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deletePreferensi(String id) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _notifikasiService.deletePreferensi(id);
      _preferensiList.removeWhere((p) => p.id == id);
      await _notifikasiService.cachePreferensiList(_preferensiList);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> scheduleNotifications(List<PreferensiNotifikasi> preferensiList) async {
    try {
      await _notifikasiService.scheduleNotifications(preferensiList);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
