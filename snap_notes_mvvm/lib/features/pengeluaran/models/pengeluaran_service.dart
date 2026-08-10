import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:snap_notes_mvvm/features/pengeluaran/models/pengeluaran.dart';
import 'package:snap_notes_mvvm/features/pengeluaran/models/kategori.dart';
import 'package:snap_notes_mvvm/features/receipt/models/receipt.dart';

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
    List<ReceiptItem>? strukItems,
    String? imagePath,
  }) async {
    FormData formData = FormData();
    formData.fields.addAll([
      MapEntry('deskripsi', deskripsi),
      MapEntry('jumlah', jumlah.toString()),
      MapEntry('tanggal', DateTime.utc(tanggal.year, tanggal.month, tanggal.day).toIso8601String()),
    ]);

    if (kategoriId != null) {
      formData.fields.add(MapEntry('kategoriId', kategoriId));
    }

    if (catatan != null) {
      formData.fields.add(MapEntry('catatan', catatan));
    }

    if (strukItems != null) {
      formData.fields.add(MapEntry('struk', jsonEncode({
        'items': strukItems.map((item) => {
          'name': item.name,
          'quantity': item.quantity,
          'price': item.price,
          'discount': item.discount,
          'total_price': item.totalPrice,
          'categoryId': item.categoryId,
          'categoryName': item.categoryName,
        }).toList(),
      })));
    }

    if (imagePath != null) {
      formData.files.add(MapEntry(
        'gambar',
        await MultipartFile.fromFile(imagePath),
      ));
    }

    final response = await _dio.post(
      '/api/pengeluaran',
      data: formData,
    );
    final envelope = response.data as Map<String, dynamic>;
    return Pengeluaran.fromJson(envelope['data'] as Map<String, dynamic>);
  }

  /// Get daftar pengeluaran (paginated)
  Future<Map<String, dynamic>> getDaftarPengeluaran({
    int? bulan,
    int? tahun,
    int page = 1,
    int limit = 10,
  }) async {
    final queryParameters = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (bulan != null) queryParameters['bulan'] = bulan;
    if (tahun != null) queryParameters['tahun'] = tahun;

    final response = await _dio.get(
      '/api/pengeluaran',
      queryParameters: queryParameters,
    );
    final envelope = response.data as Map<String, dynamic>;
    final dataObject = envelope['data'] as Map<String, dynamic>;
    final list = dataObject['data'] as List;
    final meta = dataObject['meta'] as Map<String, dynamic>;

    return {
      'data': list.map((e) => Pengeluaran.fromJson(e as Map<String, dynamic>)).toList(),
      'meta': meta,
    };
  }

  /// Get ringkasan/overview pengeluaran
  Future<Map<String, dynamic>> getPengeluaranOverview({
    int? bulan,
    int? tahun,
  }) async {
    final queryParameters = <String, dynamic>{};
    if (bulan != null) queryParameters['bulan'] = bulan;
    if (tahun != null) queryParameters['tahun'] = tahun;

    final response = await _dio.get(
      '/api/pengeluaran/overview',
      queryParameters: queryParameters,
    );
    final envelope = response.data as Map<String, dynamic>;
    return envelope['data'] as Map<String, dynamic>;
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
    String? strukId,
    List<ReceiptItem>? strukItems,
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
        // Jika ada pengubahan dari mode struk
        if (strukItems != null)
           'struk': {
             'items': strukItems.map((item) => {
               'name': item.name,
               'quantity': item.quantity,
               'price': item.price,
               'discount': item.discount,
               'total_price': item.totalPrice,
               'categoryId': item.categoryId,
             }).toList(),
           },
      },
    );
    final envelope = response.data as Map<String, dynamic>;

    if (strukId != null && strukItems != null) {
      // Calculate gross total item before discount, and accumulate total discounts
      double totalItem = 0.0;
      double totalDiscount = 0.0;
      for (final item in strukItems) {
        totalItem += item.quantity * item.price;
        if (item.discount != null && item.discount! > 0) {
          totalDiscount += item.discount!;
        }
      }

      final strukData = {
        'namaToko': deskripsi,
        'total': jumlah,
        'totalItem': totalItem,
        'diskon': totalDiscount > 0 ? totalDiscount : null,
        'tanggalBelanja': tanggal != null ? DateTime.utc(tanggal.year, tanggal.month, tanggal.day).toIso8601String() : null,
        'kategoriId': kategoriId,
        'items': strukItems.map((item) => {
          'kategoriId': item.categoryId,
          'namaItem': item.name,
          'jumlah': item.quantity,
          'hargaSatuan': item.price,
          'diskon': item.discount,
          'subtotal': item.totalPrice,
        }).toList(),
      };

      await _dio.patch(
        '/api/struk/$strukId',
        data: strukData,
      );

      final updatedResponse = await _dio.get('/api/pengeluaran/$id');
      final updatedEnvelope = updatedResponse.data as Map<String, dynamic>;
      return Pengeluaran.fromJson(updatedEnvelope['data'] as Map<String, dynamic>);
    }

    return Pengeluaran.fromJson(envelope['data'] as Map<String, dynamic>);
  }

  /// Hapus pengeluaran
  Future<void> hapusPengeluaran(String id) async {
    await _dio.delete('/api/pengeluaran/$id');
  }

  /// Proses ulang struk dengan LLM menggunakan prompt koreksi
  Future<void> reparseStruk(String strukId, String prompt) async {
    await _dio.post(
      '/api/struk/$strukId/reparse',
      data: {
        'prompt': prompt,
      },
    );
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
