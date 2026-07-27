import 'dart:convert';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:snap_notes_mvvm/core/error/exceptions.dart';

class LocalLlmService {
  final String modelUrl =
      'https://huggingface.co/buckets/randy-ar/Gemma3-1B-IT-bucket/resolve/gemma3-1b-it-int4.task';

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Inisialisasi dan pastikan model terdownload.
  /// Membutuhkan callback onProgress(int progress) untuk UI loader.
  Future<void> initializeModel({required Function(int) onProgress}) async {
    try {
      // Install dan unduh model
      await FlutterGemma.installModel(modelType: ModelType.gemmaIt)
          .fromNetwork(modelUrl)
          .withProgress(onProgress)
          .install();
      
      _isInitialized = true;
    } catch (e) {
      _isInitialized = false;
      throw LocalException('Gagal mengunduh atau memuat model LLM lokal: ${e.toString()}');
    }
  }

  /// Melakukan request parsing struk menggunakan Gemma lokal
  Future<String> parseReceiptData(String rawText, {String? customPrompt}) async {
    if (!_isInitialized) {
      throw LocalException('Model LLM lokal belum diinisialisasi.');
    }

    try {
      final model = await FlutterGemma.getActiveModel(maxTokens: 2048);
      
      String systemInstruction = '''
Anda adalah AI asisten untuk aplikasi Snap Notes.
Tugas Anda adalah mem-parsing teks mentah hasil OCR dari struk belanja ke dalam format JSON yang valid.
Struktur JSON yang diharapkan:
{
  "namaToko": "Nama Toko (String)",
  "total": 15000 (Number, total belanja dari struk),
  "items": [
    {
      "nama": "Nama Barang (String)",
      "jumlah": 1 (Number),
      "hargaSatuan": 10000 (Number),
      "totalHarga": 10000 (Number)
    }
  ]
}
HANYA hasilkan JSON yang valid, tanpa tambahan teks atau penjelasan apa pun.
''';

      if (customPrompt != null && customPrompt.isNotEmpty) {
        systemInstruction += '\nInstruksi Tambahan dari pengguna: $customPrompt';
      }

      final chat = await model.createChat(
        systemInstruction: systemInstruction,
      );

      await chat.addQueryChunk(Message.text(
        text: 'Parse teks berikut menjadi JSON:\n\n$rawText',
        isUser: true,
      ));

      final response = await chat.generateChatResponse();
      await model.close();
      
      String responseText = response is TextResponse ? response.token : response.toString();
      
      return _sanitizeAndFormatLlmJson(responseText);
    } catch (e) {
      throw LocalException('Gagal mem-parsing struk secara lokal: ${e.toString()}');
    }
  }

  /// Membersihkan output JSON dari LLM lokal
  /// LLM lokal (Gemma) kadang mengembalikan angka dalam format string seperti "Rp 15.000"
  /// Fungsi ini memastikan formatnya sesuai dengan ekspektasi backend (Number).
  String _sanitizeAndFormatLlmJson(String rawLlmResponse) {
    try {
      String cleanJson = rawLlmResponse.trim();
      
      // 1. Hapus markdown code blocks jika ada
      if (cleanJson.startsWith('```json')) {
        cleanJson = cleanJson.substring(7);
      } else if (cleanJson.startsWith('```')) {
        cleanJson = cleanJson.substring(3);
      }
      if (cleanJson.endsWith('```')) {
        cleanJson = cleanJson.substring(0, cleanJson.length - 3);
      }
      cleanJson = cleanJson.trim();

      // 2. Decode ke Map
      final Map<String, dynamic> parsedMap = jsonDecode(cleanJson);

      // Helper function untuk konversi apa pun ke int (membersihkan karakter non-digit)
      int parseLlmInt(dynamic value) {
        if (value == null) return 0;
        if (value is int) return value;
        if (value is double) return value.toInt();
        String strValue = value.toString();
        // Hapus semua karakter selain angka
        String cleanString = strValue.replaceAll(RegExp(r'[^0-9]'), '');
        return int.tryParse(cleanString) ?? 0;
      }

      // 3. Bersihkan field-field angka (ubah ke int)
      if (parsedMap.containsKey('total')) {
        parsedMap['total'] = parseLlmInt(parsedMap['total']);
      }
      
      if (parsedMap.containsKey('items') && parsedMap['items'] is List) {
        final List<dynamic> items = parsedMap['items'];
        for (var i = 0; i < items.length; i++) {
          if (items[i] is Map<String, dynamic>) {
            final Map<String, dynamic> item = items[i];
            if (item.containsKey('jumlah')) item['jumlah'] = parseLlmInt(item['jumlah']);
            if (item.containsKey('hargaSatuan')) item['hargaSatuan'] = parseLlmInt(item['hargaSatuan']);
            if (item.containsKey('totalHarga')) item['totalHarga'] = parseLlmInt(item['totalHarga']);
          }
        }
      }

      // 4. Encode kembali menjadi JSON string yang sudah dibersihkan
      return jsonEncode(parsedMap);
    } catch (e) {
      // Jika gagal decode, kembalikan teks aslinya, 
      // agar di-handle lebih lanjut oleh pemanggil fungsi (ReceiptService)
      return rawLlmResponse; 
    }
  }
}
