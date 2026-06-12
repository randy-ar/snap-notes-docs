import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../models/preferensi_notifikasi_model.dart';

abstract class NotifikasiRemoteDataSource {
  Future<List<PreferensiNotifikasiModel>> getPreferensiList();
  Future<PreferensiNotifikasiModel> createPreferensi(PreferensiNotifikasiModel model);
  Future<PreferensiNotifikasiModel> updatePreferensi(String id, PreferensiNotifikasiModel model);
  Future<void> deletePreferensi(String id);
}

class NotifikasiRemoteDataSourceImpl implements NotifikasiRemoteDataSource {
  final Dio dio;

  NotifikasiRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<PreferensiNotifikasiModel>> getPreferensiList() async {
    try {
      final response = await dio.get('/api/notifikasi/preferensi');
      final envelope = response.data as Map<String, dynamic>;
      final data = envelope['data'] as List;
      return data.map((json) => PreferensiNotifikasiModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Terjadi kesalahan server');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<PreferensiNotifikasiModel> createPreferensi(PreferensiNotifikasiModel model) async {
    try {
      final response = await dio.post(
        '/api/notifikasi/preferensi',
        data: model.toJson(),
      );
      final envelope = response.data as Map<String, dynamic>;
      return PreferensiNotifikasiModel.fromJson(envelope['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Terjadi kesalahan server');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<PreferensiNotifikasiModel> updatePreferensi(String id, PreferensiNotifikasiModel model) async {
    try {
      final response = await dio.patch(
        '/api/notifikasi/preferensi/$id',
        data: model.toJson(),
      );
      final envelope = response.data as Map<String, dynamic>;
      return PreferensiNotifikasiModel.fromJson(envelope['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Terjadi kesalahan server');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deletePreferensi(String id) async {
    try {
      await dio.delete('/api/notifikasi/preferensi/$id');
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Terjadi kesalahan server');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
