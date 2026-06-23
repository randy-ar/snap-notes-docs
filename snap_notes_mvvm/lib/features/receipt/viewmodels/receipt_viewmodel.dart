import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:snap_notes_mvvm/features/receipt/models/receipt_service.dart';
import 'package:snap_notes_mvvm/features/receipt/models/receipt.dart';
import 'package:snap_notes_mvvm/features/receipt/models/recognized_text.dart';
import 'package:snap_notes_mvvm/features/pengeluaran/models/kategori.dart';

enum ReceiptScanStep {
  camera,          // Tampilan kamera / gallery picker
  imageSelected,   // Preview gambar ter-crop
  ocrPreview,      // Bounding boxes hasil OCR ML Kit
  payloadPreview,  // Tinjau JSON payload debug sebelum dikirim
  responsePreview, // Tinjau hasil ekstraksi Gemini AI
  confirmed,       // Struk berhasil disimpan
  error            // Kesalahan scan / upload
}

class ReceiptViewModel extends ChangeNotifier {
  final ReceiptService _receiptService;

  ReceiptViewModel({required this._receiptService});

  ReceiptScanStep _currentStep = ReceiptScanStep.camera;
  ReceiptScanStep get currentStep => _currentStep;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Receipt> _receiptList = [];
  List<Receipt> get receiptList => _receiptList;

  Receipt? _receiptDetail;
  Receipt? get receiptDetail => _receiptDetail;

  List<Kategori> _categories = [];
  List<Kategori> get categories => _categories;

  File? _selectedImage;
  File? get selectedImage => _selectedImage;

  RecognizedText? _recognizedText;
  RecognizedText? get recognizedText => _recognizedText;

  Map<String, dynamic>? _payload;
  Map<String, dynamic>? get payload => _payload;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _stackTrace;
  String? get stackTrace => _stackTrace;

  Map<String, dynamic>? _serverResponse;
  Map<String, dynamic>? get serverResponse => _serverResponse;

  int? _statusCode;
  int? get statusCode => _statusCode;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setStep(ReceiptScanStep step) {
    _currentStep = step;
    notifyListeners();
  }

  /// Memulai ulang alur kamera
  void startCamera() {
    _selectedImage = null;
    _recognizedText = null;
    _payload = null;
    _receiptDetail = null;
    _errorMessage = null;
    _stackTrace = null;
    _serverResponse = null;
    _statusCode = null;
    _setStep(ReceiptScanStep.camera);
  }

  /// Gambar dipilih/cropper selesai
  void selectImage(File image) {
    _selectedImage = image;
    _errorMessage = null;
    _setStep(ReceiptScanStep.imageSelected);
  }

  /// Batalkan pemindaian saat ini
  void cancelScan() {
    startCamera();
  }

  /// Ekstraksi teks OCR menggunakan Google ML Kit secara lokal
  Future<void> runOCR() async {
    if (_selectedImage == null) return;
    _setLoading(true);
    _errorMessage = null;
    try {
      final textResult = await _receiptService.extractTextFromImage(_selectedImage!);
      _recognizedText = textResult;
      _setStep(ReceiptScanStep.ocrPreview);
    } catch (e, stack) {
      _errorMessage = e.toString();
      _stackTrace = stack.toString();
      _setStep(ReceiptScanStep.error);
    } finally {
      _setLoading(false);
    }
  }

  /// Mempersiapkan JSON payload untuk tinjauan debug
  void proceedToPayload() {
    if (_recognizedText == null || _selectedImage == null) return;
    try {
      _payload = {
        'rawText': _recognizedText!.text,
        'imagePath': _selectedImage!.path,
        'imageSize': {
          'width': _recognizedText!.imageWidth,
          'height': _recognizedText!.imageHeight,
        },
        'linesCount': _recognizedText!.lines.length,
        'lines': _recognizedText!.lines.map((line) => {
          'lineIndex': line.lineIndex,
          'text': line.text,
          'boundingBox': {
            'left': line.boundingBox.left,
            'top': line.boundingBox.top,
            'right': line.boundingBox.right,
            'bottom': line.boundingBox.bottom,
          },
        }).toList(),
      };
      _setStep(ReceiptScanStep.payloadPreview);
    } catch (e, stack) {
      _errorMessage = 'Gagal menyiapkan payload: $e';
      _stackTrace = stack.toString();
      _setStep(ReceiptScanStep.error);
    }
  }

  /// Upload gambar dan kirim rawText hasil OCR ke backend REST API (Gemini AI)
  Future<void> uploadToServer([String? customPrompt]) async {
    if (_selectedImage == null || _recognizedText == null) return;
    _setLoading(true);
    _errorMessage = null;
    try {
      final receipt = await _receiptService.parseReceipt(
        _recognizedText!.text,
        _selectedImage!,
        _recognizedText!.lines,
        _recognizedText!.imageWidth,
        _recognizedText!.imageHeight,
        customPrompt,
      );
      _receiptDetail = receipt;
      _setStep(ReceiptScanStep.responsePreview);
    } catch (e, stack) {
      _errorMessage = e.toString();
      _stackTrace = stack.toString();
      if (e.toString().contains('Server Error') || e.toString().contains('ServerException')) {
        // Coba baca properti exception jika ada
        try {
          // parse properties jika dilemparkan oleh Exception
        } catch (_) {}
      }
      _setStep(ReceiptScanStep.error);
    } finally {
      _setLoading(false);
    }
  }

  /// Melakukan reparsing (koreksi) atau update manual kategori struk
  Future<void> koreksiReceipt({String? prompt, String? kategoriId}) async {
    if (_receiptDetail == null) return;
    _setLoading(true);
    _errorMessage = null;
    try {
      if (prompt != null && prompt.trim().isNotEmpty) {
        _receiptDetail = await _receiptService.reparseReceipt(
          _receiptDetail!.id!,
          prompt.trim(),
        );
      }
      if (kategoriId != null && kategoriId.isNotEmpty) {
        _receiptDetail = await _receiptService.updateReceiptCategory(
          _receiptDetail!.id!,
          kategoriId,
        );
      }
    } catch (e, stack) {
      _errorMessage = e.toString();
      _stackTrace = stack.toString();
      // Tetap di responsePreview, tapi bisa tampilkan error melalui UI jika butuh
      _setStep(ReceiptScanStep.error);
    } finally {
      _setLoading(false);
    }
  }

  /// Memuat daftar kategori pengeluaran
  Future<void> loadCategories() async {
    try {
      final list = await _receiptService.getDaftarKategori(jenis: 'PENGELUARAN');
      _categories = list;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  /// Konfirmasi data struk yang sudah berhasil disimpan
  void confirmReceipt() {
    if (_receiptDetail != null) {
      _setStep(ReceiptScanStep.confirmed);
    }
  }

  /// Muat daftar struk untuk riwayat
  Future<void> loadReceipts(String month, String year) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final list = await _receiptService.getReceipts(month, year);
      _receiptList = list;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Muat detail struk berdasarkan ID
  Future<void> getReceiptDetail(String id) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final receipt = await _receiptService.getReceiptDetail(id);
      _receiptDetail = receipt;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }
}
