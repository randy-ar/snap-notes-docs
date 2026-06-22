import 'package:dio/dio.dart';
import 'package:snap_notes_mvvm/features/pengeluaran/models/pengeluaran.dart';
import 'package:snap_notes_mvvm/features/pengeluaran/models/kategori.dart';

/// Service untuk mengelola data pengeluaran
class PengeluaranService {
  final Dio _dio;

  PengeluaranService({required this._dio});

  /// Tambah pengeluaran baru
  Future<Pengeluaran> tambahPengeluaran({
    required String deskripsi,
    required double jumlah,
    required DateTime tanggal,
    String? kategoriId,
    String? catatan,
  }) async {
    final response = await _dio.post(
      '/api/pengeluaran',
      data: {
        'deskripsi': deskripsi,
        'jumlah': jumlah,
        'tanggal': DateTime.utc(tanggal.year, tanggal.month, tanggal.day).toIso8601String(),
        'kategoriId': kategoriId,
        'catatan': catatan,
      },
    );
    final envelope = response.data as Map<String, dynamic>;
    return Pengeluaran.fromJson(envelope['data'] as Map<String, dynamic>);
  }

  /// Get daftar pengeluaran
  Future<List<Pengeluaran>> getDaftarPengeluaran({
    int? bulan,
    int? tahun,
  }) async {
    final queryParameters = <String, dynamic>{};
    if (bulan != null) queryParameters['bulan'] = bulan;
    if (tahun != null) queryParameters['tahun'] = tahun;

    final response = await _dio.get(
      '/api/pengeluaran',
      queryParameters: queryParameters,
    );
    final envelope = response.data as Map<String, dynamic>;
    final list = envelope['data'] as List;
    return list
        .map((e) => Pengeluaran.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Get detail pengeluaran
  Future<Pengeluaran> getPengeluaranDetail(String id) async {
    final response = await _dio.get('/api/pengeluaran/$id');
    final envelope = response.data as Map<String, dynamic>;
    return Pengeluaran.fromJson(envelope['data'] as Map<String, dynamic>);
  }

  /// Update pengeluaran
  Future<Pengeluaran> updatePengeluaran(
    String id, {
    String? deskripsi,
    double? jumlah,
    DateTime? tanggal,
    String? kategoriId,
    String? catatan,
  }) async {
    final response = await _dio.patch(
      '/api/pengeluaran/$id',
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
    return Pengeluaran.fromJson(envelope['data'] as Map<String, dynamic>);
  }

  /// Hapus pengeluaran
  Future<void> hapusPengeluaran(String id) async {
    await _dio.delete('/api/pengeluaran/$id');
  }

  /// Ambil daftar kategori dari API
  Future<List<Kategori>> getDaftarKategori({String? jenis}) async {
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
  }
}
