import 'package:dio/dio.dart';
import 'package:snap_notes/features/pengeluaran/data/models/pengeluaran_model.dart';

abstract class PengeluaranRemoteDataSource {
  Future<PengeluaranModel> tambahPengeluaran({
    required String deskripsi,
    required double jumlah,
    required DateTime tanggal,
    String? kategoriId,
    String? catatan,
  });

  Future<List<PengeluaranModel>> getDaftarPengeluaran({
    int? bulan,
    int? tahun,
  });

  Future<PengeluaranModel> getPengeluaranDetail(String id);

  Future<PengeluaranModel> updatePengeluaran(
    String id, {
    String? deskripsi,
    double? jumlah,
    DateTime? tanggal,
    String? kategoriId,
    String? catatan,
  });

  Future<void> hapusPengeluaran(String id);
}

class PengeluaranRemoteDataSourceImpl implements PengeluaranRemoteDataSource {
  final Dio dio;

  PengeluaranRemoteDataSourceImpl({required this.dio});

  @override
  Future<PengeluaranModel> tambahPengeluaran({
    required String deskripsi,
    required double jumlah,
    required DateTime tanggal,
    String? kategoriId,
    String? catatan,
  }) async {
    final response = await dio.post(
      '/api/pengeluaran',
      data: {
        'deskripsi': deskripsi,
        'jumlah': jumlah,
        'tanggal': DateTime.utc(tanggal.year, tanggal.month, tanggal.day).toIso8601String(),
        if (kategoriId != null) 'kategoriId': kategoriId,
        if (catatan != null) 'catatan': catatan,
      },
    );
    final envelope = response.data as Map<String, dynamic>;
    return PengeluaranModel.fromJson(envelope['data'] as Map<String, dynamic>);
  }

  @override
  Future<List<PengeluaranModel>> getDaftarPengeluaran({
    int? bulan,
    int? tahun,
  }) async {
    final queryParameters = <String, dynamic>{};
    if (bulan != null) queryParameters['bulan'] = bulan;
    if (tahun != null) queryParameters['tahun'] = tahun;

    final response = await dio.get(
      '/api/pengeluaran',
      queryParameters: queryParameters,
    );
    final envelope = response.data as Map<String, dynamic>;
    final list = envelope['data'] as List;
    return list.map((e) => PengeluaranModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<PengeluaranModel> getPengeluaranDetail(String id) async {
    final response = await dio.get('/api/pengeluaran/$id');
    final envelope = response.data as Map<String, dynamic>;
    return PengeluaranModel.fromJson(envelope['data'] as Map<String, dynamic>);
  }

  @override
  Future<PengeluaranModel> updatePengeluaran(
    String id, {
    String? deskripsi,
    double? jumlah,
    DateTime? tanggal,
    String? kategoriId,
    String? catatan,
  }) async {
    final response = await dio.patch(
      '/api/pengeluaran/$id',
      data: {
        if (deskripsi != null) 'deskripsi': deskripsi,
        if (jumlah != null) 'jumlah': jumlah,
        if (tanggal != null) 'tanggal': DateTime.utc(tanggal.year, tanggal.month, tanggal.day).toIso8601String(),
        if (kategoriId != null) 'kategoriId': kategoriId,
        if (catatan != null) 'catatan': catatan,
      },
    );
    final envelope = response.data as Map<String, dynamic>;
    return PengeluaranModel.fromJson(envelope['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> hapusPengeluaran(String id) async {
    await dio.delete('/api/pengeluaran/$id');
  }
}
