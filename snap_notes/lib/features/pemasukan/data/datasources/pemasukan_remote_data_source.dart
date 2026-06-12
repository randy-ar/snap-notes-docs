import 'package:dio/dio.dart';
import 'package:snap_notes/features/pemasukan/data/models/pemasukan_model.dart';

abstract class PemasukanRemoteDataSource {
  Future<PemasukanModel> tambahPemasukan({
    required String deskripsi,
    required double jumlah,
    required DateTime tanggal,
    String? kategoriId,
    String? catatan,
  });

  Future<List<PemasukanModel>> getDaftarPemasukan({
    int? bulan,
    int? tahun,
  });

  Future<PemasukanModel> getPemasukanDetail(String id);

  Future<PemasukanModel> updatePemasukan(
    String id, {
    String? deskripsi,
    double? jumlah,
    DateTime? tanggal,
    String? kategoriId,
    String? catatan,
  });

  Future<void> hapusPemasukan(String id);
}

class PemasukanRemoteDataSourceImpl implements PemasukanRemoteDataSource {
  final Dio dio;

  PemasukanRemoteDataSourceImpl({required this.dio});

  @override
  Future<PemasukanModel> tambahPemasukan({
    required String deskripsi,
    required double jumlah,
    required DateTime tanggal,
    String? kategoriId,
    String? catatan,
  }) async {
    final response = await dio.post(
      '/api/pemasukan',
      data: {
        'deskripsi': deskripsi,
        'jumlah': jumlah,
        'tanggal': DateTime.utc(tanggal.year, tanggal.month, tanggal.day).toIso8601String(),
        if (kategoriId != null) 'kategoriId': kategoriId,
        if (catatan != null) 'catatan': catatan,
      },
    );
    final envelope = response.data as Map<String, dynamic>;
    return PemasukanModel.fromJson(envelope['data'] as Map<String, dynamic>);
  }

  @override
  Future<List<PemasukanModel>> getDaftarPemasukan({
    int? bulan,
    int? tahun,
  }) async {
    final queryParameters = <String, dynamic>{};
    if (bulan != null) queryParameters['bulan'] = bulan;
    if (tahun != null) queryParameters['tahun'] = tahun;

    final response = await dio.get(
      '/api/pemasukan',
      queryParameters: queryParameters,
    );
    final envelope = response.data as Map<String, dynamic>;
    final list = envelope['data'] as List;
    return list.map((e) => PemasukanModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<PemasukanModel> getPemasukanDetail(String id) async {
    final response = await dio.get('/api/pemasukan/$id');
    final envelope = response.data as Map<String, dynamic>;
    return PemasukanModel.fromJson(envelope['data'] as Map<String, dynamic>);
  }

  @override
  Future<PemasukanModel> updatePemasukan(
    String id, {
    String? deskripsi,
    double? jumlah,
    DateTime? tanggal,
    String? kategoriId,
    String? catatan,
  }) async {
    final response = await dio.patch(
      '/api/pemasukan/$id',
      data: {
        if (deskripsi != null) 'deskripsi': deskripsi,
        if (jumlah != null) 'jumlah': jumlah,
        if (tanggal != null) 'tanggal': DateTime.utc(tanggal.year, tanggal.month, tanggal.day).toIso8601String(),
        if (kategoriId != null) 'kategoriId': kategoriId,
        if (catatan != null) 'catatan': catatan,
      },
    );
    final envelope = response.data as Map<String, dynamic>;
    return PemasukanModel.fromJson(envelope['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> hapusPemasukan(String id) async {
    await dio.delete('/api/pemasukan/$id');
  }
}
