import 'package:dio/dio.dart';
import 'package:snap_notes_mvvm/core/error/exceptions.dart';
import 'package:snap_notes_mvvm/features/pemasukan/models/pemasukan.dart';
import 'package:snap_notes_mvvm/features/pengeluaran/models/kategori.dart';

/// Service untuk mengelola data pemasukan
class PemasukanService {
  final Dio _dio;

  PemasukanService({required this._dio});

  String _handleDioError(DioException e) {
    if (e.response?.data != null && e.response!.data is Map<String, dynamic>) {
      final data = e.response!.data as Map<String, dynamic>;
      if (data.containsKey('message')) {
        return data['message'] as String;
      }
    }
    switch (e.response?.statusCode) {
      case 400:
        return 'Data tidak valid. Silakan periksa kembali.';
      case 401:
        return 'Sesi tidak valid, silakan login kembali.';
      case 403:
        return 'Anda tidak memiliki akses untuk melakukan ini.';
      case 404:
        return 'Data pemasukan tidak ditemukan.';
      case 409:
        return 'Data sudah ada atau terjadi konflik.';
      case 500:
        return 'Terjadi kesalahan server. Silakan coba lagi nanti.';
      default:
        return e.message ?? 'Terjadi kesalahan jaringan.';
    }
  }

  /// Tambah pemasukan baru
  Future<Pemasukan> createPemasukan({
    required String deskripsi,
    required double jumlah,
    required DateTime tanggal,
    String? kategoriId,
    String? catatan,
  }) async {
    try {
      final response = await _dio.post(
        '/api/pemasukan',
        data: {
          'deskripsi': deskripsi,
          'jumlah': jumlah,
          'tanggal': DateTime.utc(tanggal.year, tanggal.month, tanggal.day).toIso8601String(),
          'kategoriId': kategoriId,
          'catatan': catatan,
        },
      );
      final envelope = response.data as Map<String, dynamic>;
      return Pemasukan.fromJson(envelope['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(_handleDioError(e));
    }
  }

  /// Get daftar pemasukan
  Future<List<Pemasukan>> getPemasukan({
    int? bulan,
    int? tahun,
  }) async {
    try {
      final queryParameters = <String, dynamic>{};
      if (bulan != null) queryParameters['bulan'] = bulan;
      if (tahun != null) queryParameters['tahun'] = tahun;

      final response = await _dio.get(
        '/api/pemasukan',
        queryParameters: queryParameters,
      );
      final envelope = response.data as Map<String, dynamic>;
      final list = envelope['data'] as List;
      return list
          .map((e) => Pemasukan.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(_handleDioError(e));
    }
  }

  /// Get detail pemasukan
  Future<Pemasukan> getPemasukanDetail(String id) async {
    try {
      final response = await _dio.get('/api/pemasukan/$id');
      final envelope = response.data as Map<String, dynamic>;
      return Pemasukan.fromJson(envelope['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(_handleDioError(e));
    }
  }

  /// Update pemasukan
  Future<Pemasukan> updatePemasukan(
    String id, {
    String? deskripsi,
    double? jumlah,
    DateTime? tanggal,
    String? kategoriId,
    String? catatan,
  }) async {
    try {
      final response = await _dio.patch(
        '/api/pemasukan/$id',
        data: {
          if (deskripsi != null) 'deskripsi': deskripsi,
          if (jumlah != null) 'jumlah': jumlah,
          if (tanggal != null)
            'tanggal': DateTime.utc(tanggal.year, tanggal.month, tanggal.day).toIso8601String(),
          'kategoriId': kategoriId,
          'catatan': catatan,
        },
      );
      final envelope = response.data as Map<String, dynamic>;
      return Pemasukan.fromJson(envelope['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(_handleDioError(e));
    }
  }

  /// Hapus pemasukan
  Future<void> deletePemasukan(String id) async {
    try {
      await _dio.delete('/api/pemasukan/$id');
    } on DioException catch (e) {
      throw ServerException(_handleDioError(e));
    }
  }

  /// Ambil daftar kategori dari API
  Future<List<Kategori>> getDaftarKategori({String? jenis}) async {
    try {
      final queryParameters = <String, dynamic>{};
      if (jenis != null) queryParameters['jenis'] = jenis;

      final response = await _dio.get(
        '/api/kategori',
        queryParameters: queryParameters,
      );
      final envelope = response.data as Map<String, dynamic>;
      final list = envelope['data'] as List;
      return list
          .map((e) => Kategori.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(_handleDioError(e));
    }
  }
}
