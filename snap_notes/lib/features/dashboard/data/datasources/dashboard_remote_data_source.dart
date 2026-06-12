import 'package:dio/dio.dart';
import 'package:snap_notes/features/dashboard/data/models/ringkasan_model.dart';

abstract class DashboardRemoteDataSource {
  Future<RingkasanDashboardModel> getRingkasan({int? bulan, int? tahun});
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final Dio dio;

  DashboardRemoteDataSourceImpl({required this.dio});

  @override
  Future<RingkasanDashboardModel> getRingkasan({int? bulan, int? tahun}) async {
    final Map<String, dynamic> queryParams = {};
    if (bulan != null) queryParams['bulan'] = bulan.toString();
    if (tahun != null) queryParams['tahun'] = tahun.toString();

    final response = await dio.get('/api/dashboard/ringkasan', queryParameters: queryParams);
    
    if (response.statusCode == 200) {
      return RingkasanDashboardModel.fromJson(response.data['data']);
    } else {
      throw Exception('Gagal memuat ringkasan dashboard');
    }
  }
}
