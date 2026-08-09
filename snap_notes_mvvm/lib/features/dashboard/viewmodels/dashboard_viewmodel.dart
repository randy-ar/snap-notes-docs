import 'package:flutter/foundation.dart';
import 'package:snap_notes_mvvm/features/dashboard/models/dashboard_service.dart';
import 'package:snap_notes_mvvm/features/dashboard/models/ringkasan.dart';

class DashboardViewModel extends ChangeNotifier {
  final DashboardService _dashboardService;

  DashboardViewModel({required this._dashboardService});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  RingkasanDashboard? _ringkasan;
  RingkasanDashboard? get ringkasan => _ringkasan;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // State untuk Heatmap (Kalender Pengeluaran & Pemasukan)
  Map<DateTime, double>? _calendarPengeluaran;
  Map<DateTime, double>? get calendarPengeluaran => _calendarPengeluaran;

  Map<DateTime, double>? _calendarPemasukan;
  Map<DateTime, double>? get calendarPemasukan => _calendarPemasukan;

  // State untuk Pie Chart (Kategori Pengeluaran)
  List<Map<String, dynamic>>? _kategoriData;
  List<Map<String, dynamic>>? get kategoriData => _kategoriData;
  List<Map<String, dynamic>> _trendCache = [];
  List<Map<String, dynamic>> get trendCache => _trendCache;

  List<Map<String, dynamic>> get monthlyTrend {
    if (_trendCache.isEmpty) return [];

    int centroidIdx = _trendCache.indexWhere((t) => t['bulan'] == _focusMonth.month && t['tahun'] == _focusMonth.year);
    if (centroidIdx == -1) return [];

    int startIdx = centroidIdx - 2;
    int endIdx = centroidIdx + 3;

    if (startIdx < 0) startIdx = 0;
    if (endIdx >= _trendCache.length) endIdx = _trendCache.length - 1;

    return _trendCache.sublist(startIdx, endIdx + 1);
  }

  DateTime _focusMonth = DateTime.now();
  DateTime get focusMonth => _focusMonth;

  bool _isTrendLoading = false;
  bool get isTrendLoading => _isTrendLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> initDashboard({int? bulan, int? tahun, bool force = false}) async {
    _focusMonth = DateTime(tahun ?? DateTime.now().year, bulan ?? DateTime.now().month, 1);
    await Future.wait([
      loadRingkasan(bulan: _focusMonth.month, tahun: _focusMonth.year),
      loadMonthlyTrend(force: force),
      loadCalendarData(bulan: _focusMonth.month, tahun: _focusMonth.year),
      loadKategoriData(bulan: _focusMonth.month, tahun: _focusMonth.year),
    ]);
  }

  Future<void> loadRingkasan({int? bulan, int? tahun}) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final ringkasanData = await _dashboardService.getRingkasan(
        bulan: bulan,
        tahun: tahun,
      );
      _ringkasan = ringkasanData;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadCalendarData({int? bulan, int? tahun}) async {
    _errorMessage = null;
    try {
      final data = await _dashboardService.getKalender(
        bulan: bulan,
        tahun: tahun,
      );
      _calendarPengeluaran = data['pengeluaran'];
      _calendarPemasukan = data['pemasukan'];
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }

  Future<void> loadKategoriData({int? bulan, int? tahun}) async {
    _errorMessage = null;
    try {
      final data = await _dashboardService.getPerKategori(
        bulan: bulan,
        tahun: tahun,
      );
      _kategoriData = data;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }
  Future<void> loadMonthlyTrend({bool force = false, bool isBackground = false}) async {
    if (!force) {
      int centroidIdx = _trendCache.indexWhere((t) => t['bulan'] == _focusMonth.month && t['tahun'] == _focusMonth.year);
      if (centroidIdx != -1 && centroidIdx - 2 >= 0 && centroidIdx + 3 < _trendCache.length) {
        notifyListeners();
        return;
      }
    }

    if (!isBackground) _isTrendLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final trendData = await _dashboardService.getTrend(
        bulan: _focusMonth.month,
        tahun: _focusMonth.year,
      );

      _trendCache = trendData.map((res) {
        return {
          'bulan': res['bulan'],
          'tahun': res['tahun'],
          'totalPemasukan': (res['totalPemasukan'] as num).toDouble(),
          'totalPengeluaran': (res['totalPengeluaran'] as num).toDouble(),
          'dateTime': DateTime.parse(res['dateTime']).toLocal(),
        };
      }).toList();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      if (!isBackground) _isTrendLoading = false;
      notifyListeners();
    }
  }

  /// Geser grafik 1 bulan ke depan
  void nextMonth() {
    _focusMonth = DateTime(_focusMonth.year, _focusMonth.month + 1, 1);

    int centroidIdx = _trendCache.indexWhere((t) => t['bulan'] == _focusMonth.month && t['tahun'] == _focusMonth.year);
    if (centroidIdx != -1 && centroidIdx - 2 >= 0 && centroidIdx + 3 < _trendCache.length) {
      notifyListeners();
      // Preload background fetch jika mendekati tepi cache (margin 6 bulan)
      if (centroidIdx - 2 <= 5 || centroidIdx + 3 >= _trendCache.length - 6) {
         loadMonthlyTrend(force: true, isBackground: true);
      }
    } else {
      loadMonthlyTrend();
    }
  }

  /// Geser grafik 1 bulan ke belakang
  void prevMonth() {
    _focusMonth = DateTime(_focusMonth.year, _focusMonth.month - 1, 1);

    int centroidIdx = _trendCache.indexWhere((t) => t['bulan'] == _focusMonth.month && t['tahun'] == _focusMonth.year);
    if (centroidIdx != -1 && centroidIdx - 2 >= 0 && centroidIdx + 3 < _trendCache.length) {
      notifyListeners();
      // Preload background fetch jika mendekati tepi cache (margin 6 bulan)
      if (centroidIdx - 2 <= 5 || centroidIdx + 3 >= _trendCache.length - 6) {
         loadMonthlyTrend(force: true, isBackground: true);
      }
    } else {
      loadMonthlyTrend();
    }
  }
}
