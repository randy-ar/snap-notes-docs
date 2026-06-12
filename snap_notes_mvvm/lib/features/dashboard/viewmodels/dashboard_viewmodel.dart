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

  // State untuk Tren Bulanan (Line Chart)
  List<Map<String, dynamic>> _monthlyTrend = [];
  List<Map<String, dynamic>> get monthlyTrend => _monthlyTrend;

  DateTime _focusMonth = DateTime.now();
  DateTime get focusMonth => _focusMonth;

  bool _isTrendLoading = false;
  bool get isTrendLoading => _isTrendLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
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

  /// Memuat tren data transaksi (pemasukan & pengeluaran) 6 bulan berturut-turut
  Future<void> loadMonthlyTrend() async {
    _isTrendLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final List<DateTime> months = [];
      for (int i = 5; i >= 0; i--) {
        final date = DateTime(_focusMonth.year, _focusMonth.month - i, 1);
        months.add(date);
      }

      final futures = months.map((m) => _dashboardService.getRingkasan(bulan: m.month, tahun: m.year));
      final results = await Future.wait(futures);

      _monthlyTrend = List.generate(months.length, (index) {
        final m = months[index];
        final res = results[index];
        return {
          'bulan': m.month,
          'tahun': m.year,
          'totalPemasukan': res.totalPemasukan,
          'totalPengeluaran': res.totalPengeluaran,
          'dateTime': m,
        };
      });
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isTrendLoading = false;
      notifyListeners();
    }
  }

  /// Geser grafik 6 bulan ke depan
  void nextSixMonths() {
    _focusMonth = DateTime(_focusMonth.year, _focusMonth.month + 6, 1);
    loadMonthlyTrend();
  }

  /// Geser grafik 6 bulan ke belakang
  void prevSixMonths() {
    _focusMonth = DateTime(_focusMonth.year, _focusMonth.month - 6, 1);
    loadMonthlyTrend();
  }
}
