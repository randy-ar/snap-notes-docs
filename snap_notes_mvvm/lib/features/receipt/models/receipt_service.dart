import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart' show decodeImageFromList, Rect;
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart' hide TextLine;
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart' as mlkit show RecognizedText;
import 'package:snap_notes_mvvm/core/error/exceptions.dart';
import 'package:snap_notes_mvvm/features/receipt/models/receipt.dart';
import 'package:snap_notes_mvvm/features/receipt/models/recognized_text.dart' as local;

/// Service untuk scan dan mengelola struk
class ReceiptService {
  final Dio _dio;

  ReceiptService({required this._dio});

  /// Melakukan ekstraksi teks menggunakan Google ML Kit
  Future<local.RecognizedText> extractTextFromImage(File image) async {
    try {
      final inputImage = InputImage.fromFile(image);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      
      final mlkit.RecognizedText mlkitText = await textRecognizer.processImage(inputImage);
      await textRecognizer.close();
      
      // Mengambil dimensi gambar secara dinamis
      final decodedImage = await decodeImageFromList(await image.readAsBytes());
      final imageWidth = decodedImage.width.toDouble();
      final imageHeight = decodedImage.height.toDouble();

      final allMlkitLines = mlkitText.blocks.expand((block) => block.lines).toList();
      allMlkitLines.sort((a, b) => a.boundingBox.top.compareTo(b.boundingBox.top));

      final List<List<dynamic>> groupedLines = [];
      for (var mlkitLine in allMlkitLines) {
        if (groupedLines.isEmpty) {
          groupedLines.add([mlkitLine]);
        } else {
          final currentGroup = groupedLines.last;
          
          double groupTop = currentGroup.map((l) => l.boundingBox.top as double).reduce((a, b) => a < b ? a : b);
          double groupBottom = currentGroup.map((l) => l.boundingBox.bottom as double).reduce((a, b) => a > b ? a : b);
          
          double lineCenter = (mlkitLine.boundingBox.top + mlkitLine.boundingBox.bottom) / 2;
          double lineHeight = mlkitLine.boundingBox.bottom - mlkitLine.boundingBox.top;
          
          double threshold = lineHeight * 0.5;

          if (lineCenter >= (groupTop - threshold) && lineCenter <= (groupBottom + threshold)) {
            currentGroup.add(mlkitLine);
          } else {
            groupedLines.add([mlkitLine]);
          }
        }
      }

      int lineIndex = 0;
      final List<local.TextLine> lines = [];

      for (var group in groupedLines) {
        group.sort((a, b) => (a.boundingBox.left as double).compareTo(b.boundingBox.left as double));

        final mergedText = group.map((l) => l.text).join('   '); // Gunakan 3 spasi untuk menandakan jeda/gap

        double left = group.map((l) => l.boundingBox.left as double).reduce((a, b) => a < b ? a : b);
        double top = group.map((l) => l.boundingBox.top as double).reduce((a, b) => a < b ? a : b);
        double right = group.map((l) => l.boundingBox.right as double).reduce((a, b) => a > b ? a : b);
        double bottom = group.map((l) => l.boundingBox.bottom as double).reduce((a, b) => a > b ? a : b);

        lines.add(local.TextLine(
          lineIndex: lineIndex++,
          text: mergedText,
          boundingBox: Rect.fromLTRB(left, top, right, bottom),
        ));
      }

      final fullReconstructedText = lines.map((l) => l.text).join('\n');

      return local.RecognizedText(
        text: fullReconstructedText,
        lines: lines,
        imageWidth: imageWidth,
        imageHeight: imageHeight,
      );
    } catch (e) {
      throw LocalException('Gagal melakukan OCR pada gambar: ${e.toString()}');
    }
  }

  /// Parse struk dari hasil OCR
  Future<Receipt> parseReceipt(
    String rawText,
    File image,
    List<local.TextLine> lines,
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

      final response = await _dio.post(
        '/api/struk/scan',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data as Map<String, dynamic>;
        final receiptData = responseData['data'] as Map<String, dynamic>;
        return Receipt.fromJson(receiptData);
      } else {
        throw ServerException('Failed to parse receipt: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioException(e);
      rethrow;
    }
  }

  /// Get daftar struk
  Future<List<Receipt>> getReceipts(String month, String year) async {
    try {
      final response = await _dio.get(
        '/api/struk',
        queryParameters: {
          'bulan': month,
          'tahun': year,
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final data = responseData['data'] as List<dynamic>? ?? [];
        return data.map((json) => Receipt.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw ServerException('Failed to fetch receipts: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioException(e);
      rethrow;
    }
  }

  /// Get detail struk
  Future<Receipt> getReceiptDetail(String id) async {
    try {
      final response = await _dio.get('/api/struk/$id');

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final data = responseData['data'] as Map<String, dynamic>;
        return Receipt.fromJson(data);
      } else {
        throw ServerException('Failed to fetch receipt detail: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioException(e);
      rethrow;
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
