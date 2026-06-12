import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:snap_notes/core/error/exceptions.dart';
import 'package:snap_notes/features/receipt/data/models/receipt_model.dart';
import 'package:snap_notes/features/receipt/domain/entities/recognized_text_entity.dart';

abstract class ReceiptRemoteDataSource {
  Future<ReceiptModel> parseReceiptData(
    String rawText,
    File image,
    List<TextLineEntity> lines,
    double imageWidth,
    double imageHeight,
  );
  Future<List<ReceiptModel>> getReceipts(String month, String year);
  Future<ReceiptModel> getReceiptDetail(String id);
}

class ReceiptRemoteDataSourceImpl implements ReceiptRemoteDataSource {
  final Dio dio;

  ReceiptRemoteDataSourceImpl({required this.dio});

  @override
  Future<ReceiptModel> parseReceiptData(
    String rawText,
    File image,
    List<TextLineEntity> lines,
    double imageWidth,
    double imageHeight,
  ) async {
    try {
      final ocrData = jsonEncode({
        'rawText': rawText,
        'imageSize': {
          'width': imageWidth,
          'height': imageHeight,
        },
        'lines': lines.map((line) => {
          'lineIndex': line.lineIndex,
          'text': line.text,
          'boundingBox': {
            'left': line.boundingBox.left,
            'top': line.boundingBox.top,
            'right': line.boundingBox.right,
            'bottom': line.boundingBox.bottom,
          },
        }).toList(),
      });

      final formData = FormData.fromMap({
        'ocrData': ocrData,
        'gambar': await MultipartFile.fromFile(
          image.path,
          filename: image.path.split('/').last,
        ),
      });

      final response = await dio.post(
        '/api/struk/scan',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data as Map<String, dynamic>;
        final receiptData = responseData['data'] as Map<String, dynamic>;
        return ReceiptModel.fromJson(receiptData);
      } else {
        throw ServerException('Failed to parse receipt: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  @override
  Future<List<ReceiptModel>> getReceipts(String month, String year) async {
    try {
      final response = await dio.get(
        '/api/struk',
        queryParameters: {
          'bulan': month,
          'tahun': year,
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final data = responseData['data'] as List<dynamic>? ?? [];
        return data.map((json) => ReceiptModel.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw ServerException('Failed to fetch receipts: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  @override
  Future<ReceiptModel> getReceiptDetail(String id) async {
    try {
      final response = await dio.get('/api/struk/$id');

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final data = responseData['data'] as Map<String, dynamic>;
        return ReceiptModel.fromJson(data);
      } else {
        throw ServerException('Failed to fetch receipt detail: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  Never _handleDioException(DioException e) {
    String errorMessage = 'Unknown Dio error';
    Map<String, dynamic>? serverResponse;
    int? statusCode;
    
    if (e.response?.data != null) {
      try {
        final responseData = e.response!.data;
        if (responseData is Map<String, dynamic>) {
          serverResponse = responseData;
          final serverMessage = responseData['message'] as String?;
          final path = responseData['path'] as String?;
          statusCode = responseData['statusCode'] as int?;
          
          if (serverMessage != null) {
            errorMessage = 'Server Error ($statusCode): $serverMessage';
            if (path != null) {
              errorMessage += '\nPath: $path';
            }
          }
        }
      } catch (_) {
        errorMessage = e.message ?? 'Unknown Dio error';
      }
    } else {
      errorMessage = e.message ?? 'Unknown Dio error';
    }
    
    throw ServerException(
      errorMessage,
      serverResponse: serverResponse,
      statusCode: statusCode,
      stackTrace: StackTrace.current,
    );
  }
}
