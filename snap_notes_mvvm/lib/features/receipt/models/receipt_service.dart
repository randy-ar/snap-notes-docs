import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart' show decodeImageFromList, Rect;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as img;
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart' hide TextLine;
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart' as mlkit show RecognizedText;
import 'package:snap_notes_mvvm/core/error/exceptions.dart';
import 'package:snap_notes_mvvm/features/receipt/models/receipt.dart';
import 'package:snap_notes_mvvm/features/receipt/models/recognized_text.dart' as local;
import 'package:snap_notes_mvvm/features/pengeluaran/models/kategori.dart';

/// Service untuk scan dan mengelola struk
class ReceiptService {
  final Dio _dio;

  ReceiptService({required this._dio});

  /// Memutar gambar file sebesar angle tertentu (default 90)
  Future<File> rotateImageFile(File image, {int angle = 90}) async {
    try {
      final bytes = await image.readAsBytes();
      final decodedImage = img.decodeImage(bytes);
      if (decodedImage == null) throw Exception('Gagal mendecode gambar untuk rotasi');

      img.Image rotatedImage;
      if (angle == 90) {
        rotatedImage = img.copyRotate(decodedImage, angle: 90);
      } else if (angle == -90 || angle == 270) {
        rotatedImage = img.copyRotate(decodedImage, angle: -90);
      } else if (angle == 180) {
        rotatedImage = img.copyRotate(decodedImage, angle: 180);
      } else {
        rotatedImage = img.copyRotate(decodedImage, angle: angle);
      }

      final rotatedBytes = img.encodeJpg(rotatedImage);
      final newPath = '${image.path}_rotated_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final newFile = File(newPath);
      await newFile.writeAsBytes(rotatedBytes);
      return newFile;
    } catch (e) {
      throw LocalException('Gagal memutar gambar: ${e.toString()}');
    }
  }

  /// Melakukan kompresi file gambar seoptimal mungkin menggunakan flutter_image_compress
  /// sebelum dikirim via multipart upload.
  Future<File> compressImageFile(File image, {int minDimension = 1920, int quality = 70}) async {
    try {
      final targetPath = '${image.path}_compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        image.absolute.path,
        targetPath,
        quality: quality,
        minWidth: minDimension,
        minHeight: minDimension,
        keepExif: false,
        format: CompressFormat.jpeg,
      );

      if (compressedFile != null && await File(compressedFile.path).exists()) {
        return File(compressedFile.path);
      }
      return image;
    } catch (_) {
      return image; // Fallback jika kompresi native gagal
    }
  }

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

  /// Parse struk batch dari hasil OCR
  Future<List<Receipt>> parseReceiptBatch(
    List<Map<String, dynamic>> ocrDataBatch,
  ) async {
    final startTime = DateTime.now();
    print('[Client] parseReceiptBatch request started at $startTime');
    try {
      final response = await _dio.post(
        '/api/struk/scan/analyze',
        data: {
          'ocrDataBatch': ocrDataBatch,
        },
      );

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime).inMilliseconds;
      print('[Client] parseReceiptBatch request completed in ${duration}ms at $endTime');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data as Map<String, dynamic>;
        final receiptsData = responseData['data'] as List;
        return receiptsData.map((e) => Receipt.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        throw ServerException('Failed to parse receipt batch: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime).inMilliseconds;
      print('[Client] parseReceiptBatch request failed after ${duration}ms');
      _handleDioException(e);
      rethrow;
    }
  }

  Future<Receipt> saveReceipt(Receipt receipt, File image) async {
    try {
      final compressedImage = await compressImageFile(image);
      final receiptData = jsonEncode(receipt.toJson());

      final formData = FormData.fromMap({
        'receiptData': receiptData,
        'gambar': await MultipartFile.fromFile(
          compressedImage.path,
          filename: compressedImage.path.split('/').last,
        ),
      });

      final response = await _dio.post(
        '/api/struk/scan/save',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data as Map<String, dynamic>;
        final data = responseData['data'] as Map<String, dynamic>;
        return Receipt.fromJson(data);
      } else {
        throw ServerException('Failed to save receipt: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioException(e);
      rethrow;
    }
  }

  Future<Receipt> reparseReceipt(String strukId, String prompt) async {
    try {
      final response = await _dio.post(
        '/api/struk/$strukId/reparse',
        data: {
          'prompt': prompt,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data as Map<String, dynamic>;
        final receiptData = responseData['data'] as Map<String, dynamic>;
        return Receipt.fromJson(receiptData);
      } else {
        throw ServerException('Failed to reparse receipt: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 422 || e.response?.statusCode == 503) {
        final errorMessage = e.response?.data?['message'] ?? e.message;
        throw ServerException('AI Processing Error: $errorMessage');
      }
      throw ServerException('Failed to communicate with server: ${e.message}');
    } catch (e) {
      throw ServerException('An unexpected error occurred: $e');
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

  /// Get daftar kategori
  Future<List<Kategori>> getDaftarKategori({String? jenis}) async {
    try {
      final response = await _dio.get(
        '/api/kategori',
        queryParameters: {
          if (jenis != null) 'jenis': jenis,
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final data = responseData['data'] as List<dynamic>? ?? [];
        return data.map((json) => Kategori.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw ServerException('Failed to fetch categories: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioException(e);
      rethrow;
    }
  }

  /// Update kategori struk
  Future<Receipt> updateReceiptCategory(String id, String kategoriId) async {
    try {
      final response = await _dio.patch(
        '/api/struk/$id',
        data: {
          'kategoriId': kategoriId,
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final data = responseData['data'] as Map<String, dynamic>;
        return Receipt.fromJson(data);
      } else {
        throw ServerException('Failed to update receipt category: ${response.statusCode}');
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
            errorMessage = serverMessage;
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
