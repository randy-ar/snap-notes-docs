import 'package:dio/dio.dart';
import 'package:snap_notes_mvvm/features/dashboard/models/ringkasan.dart';

/// Service untuk dashboard
class DashboardService {
  final Dio _dio;

  DashboardService({required this._dio});

  /// Get ringkasan dashboard
  Future<RingkasanDashboard> getRingkasan({int? bulan, int? tahun}) async {
    final Map<String, dynamic> queryParams = {};
    if (bulan != null) queryParams['bulan'] = bulan.toString();
    if (tahun != null) queryParams['tahun'] = tahun.toString();

    final response = await _dio.get('/api/dashboard/ringkasan', queryParameters: queryParams);

    if (response.statusCode == 200) {
      return RingkasanDashboard.fromJson(response.data['data']);
    } else {
      throw Exception('Gagal memuat ringkasan dashboard');
    }
  }

  /// Get tren 6 bulan
  Future<List<Map<String, dynamic>>> getTrend({int? bulan, int? tahun}) async {
    final Map<String, dynamic> queryParams = {};
    if (bulan != null) queryParams['bulan'] = bulan.toString();
    if (tahun != null) queryParams['tahun'] = tahun.toString();

    final response = await _dio.get('/api/dashboard/trend', queryParameters: queryParams);

    if (response.statusCode == 200) {
      final list = response.data['data'] as List;
      return list.map((e) => e as Map<String, dynamic>).toList();
    } else {
      throw Exception('Gagal memuat tren dashboard');
    }
  }

  Future<Map<DateTime, double>> getKalender({int? bulan, int? tahun}) async {
    final Map<String, dynamic> queryParams = {};
    if (bulan != null) queryParams['bulan'] = bulan.toString();
    if (tahun != null) queryParams['tahun'] = tahun.toString();

    final response = await _dio.get('/api/dashboard/kalender', queryParameters: queryParams);

    if (response.statusCode == 200) {
      final map = response.data['data'] as Map<String, dynamic>;
      final result = <DateTime, double>{};
      map.forEach((key, value) {
        result[DateTime.parse(key)] = (value as num).toDouble();
      });
      return result;
    } else {
      throw Exception('Gagal memuat kalender dashboard');
    }
  }

  /// Get data kategori
  Future<List<Map<String, dynamic>>> getPerKategori({int? bulan, int? tahun}) async {
    final Map<String, dynamic> queryParams = {};
    if (bulan != null) queryParams['bulan'] = bulan.toString();
    if (tahun != null) queryParams['tahun'] = tahun.toString();

    final response = await _dio.get('/api/dashboard/kategori', queryParameters: queryParams);

    if (response.statusCode == 200) {
      final list = response.data['data'] as List;
      return list.map((e) => e as Map<String, dynamic>).toList();
    } else {
      throw Exception('Gagal memuat kategori dashboard');
    }
  }
}
