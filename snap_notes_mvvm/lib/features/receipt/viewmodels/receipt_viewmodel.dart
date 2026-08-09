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

  bool _isBatchMode = false;
  bool get isBatchMode => _isBatchMode;

  List<File> _selectedImages = [];
  List<File> get selectedImages => _selectedImages;

  List<RecognizedText> _recognizedTexts = [];
  List<RecognizedText> get recognizedTexts => _recognizedTexts;

  List<Receipt> _batchReceipts = [];
  List<Receipt> get batchReceipts => _batchReceipts;

  bool _isLoading = false;
  bool get isLoading => _isLoading;



  bool _isUploading = false;
  bool get isUploading => _isUploading;

  void _setUploading(bool value) {
    _isUploading = value;
    notifyListeners();
  }

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

  void updateReceiptManual(Receipt updatedReceipt, {int? batchIndex}) {
    if (_isBatchMode && batchIndex != null && batchIndex >= 0 && batchIndex < _batchReceipts.length) {
      _batchReceipts[batchIndex] = updatedReceipt;
    } else {
      _receiptDetail = updatedReceipt;
    }
    notifyListeners();
  }

  /// Memulai ulang alur kamera
  void startCamera() {
    _selectedImage = null;
    _selectedImages = [];
    _isBatchMode = false;
    _recognizedText = null;
    _recognizedTexts = [];
    _batchReceipts = [];
    _payload = null;
    _receiptDetail = null;
    _errorMessage = null;
    _stackTrace = null;
    _serverResponse = null;
    _statusCode = null;
    _setStep(ReceiptScanStep.camera);
  }

  /// Gambar dipilih (mode batch)
  void selectImages(List<File> images) {
    if (images.isEmpty) return;
    _isBatchMode = images.length > 1;
    _selectedImages = images;
    _selectedImage = images.first;
    _errorMessage = null;
    _setStep(ReceiptScanStep.imageSelected);
  }

  /// Gambar dipilih/cropper selesai
  void selectImage(File image) {
    _selectedImage = image;
    _errorMessage = null;
    _setStep(ReceiptScanStep.imageSelected);
  }

  Future<void> processBatchCrop(List<File> files) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      _isBatchMode = files.length > 1;
      _selectedImages = files;
      _selectedImage = files.first;
      _recognizedTexts = [];
      _batchReceipts = [];

      for (var file in files) {
        final recognizedText = await _receiptService.extractTextFromImage(file);
        _recognizedTexts.add(recognizedText);
      }

      if (_recognizedTexts.isNotEmpty) {
        _recognizedText = _recognizedTexts.first;
      }
      _setStep(ReceiptScanStep.ocrPreview);
    } catch (e, stack) {
      _errorMessage = "Gagal memproses gambar batch: $e";
      _stackTrace = stack.toString();
      _setStep(ReceiptScanStep.error);
    } finally {
      _setLoading(false);
    }
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
      print('=== HASIL TEXT OCR (runOCR) ===');
      print(textResult.text);
      print('===============================');
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

  /// Hapus satu gambar dari batch
  void removeBatchImage(int index) {
    if (!_isBatchMode || index < 0 || index >= _selectedImages.length) return;

    _selectedImages.removeAt(index);
    if (index < _recognizedTexts.length) {
      _recognizedTexts.removeAt(index);
    }

    if (_selectedImages.isEmpty) {
      startCamera();
    } else {
      if (_selectedImages.length == 1) {
        _isBatchMode = false;
        _selectedImage = _selectedImages.first;
        if (_recognizedTexts.isNotEmpty) {
          _recognizedText = _recognizedTexts.first;
        }
      } else {
        // adjust if removing the first item
        _selectedImage = _selectedImages.first;
        if (_recognizedTexts.isNotEmpty) {
          _recognizedText = _recognizedTexts.first;
        }
      }
      notifyListeners();
    }
  }
  Future<void> rotateBatchImage(int index, {int angle = 90}) async {
    if (!_isBatchMode || index < 0 || index >= _selectedImages.length) return;
    _setLoading(true);
    _errorMessage = null;
    try {
      final rotatedImage = await _receiptService.rotateImageFile(_selectedImages[index], angle: angle);
      _selectedImages[index] = rotatedImage;
      if (index == 0) _selectedImage = rotatedImage;

      final textResult = await _receiptService.extractTextFromImage(rotatedImage);
      _recognizedTexts[index] = textResult;
      if (index == 0) _recognizedText = textResult;
    } catch (e, stack) {
      _errorMessage = 'Gagal memutar gambar: $e';
      _stackTrace = stack.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Memutar gambar single dan re-run OCR
  Future<void> rotateImage({int angle = 90}) async {
    if (_selectedImage == null) return;
    _setLoading(true);
    _errorMessage = null;
    try {
      final rotatedImage = await _receiptService.rotateImageFile(_selectedImage!, angle: angle);
      _selectedImage = rotatedImage;
      await runOCR();
    } catch (e, stack) {
      _errorMessage = 'Gagal memutar gambar: $e';
      _stackTrace = stack.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> runBatchOCR() async {
    if (_selectedImages.isEmpty) return;
    _setLoading(true);
    _errorMessage = null;
    try {
      _recognizedTexts = [];
      for (final image in _selectedImages) {
        final textResult = await _receiptService.extractTextFromImage(image);
        _recognizedTexts.add(textResult);
      }
      if (_recognizedTexts.isNotEmpty) {
        _recognizedText = _recognizedTexts.first;
      }
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

  /// Upload batch gambar ke backend
  Future<void> uploadBatchToServer([String? customPrompt]) async {
    if (_selectedImages.isEmpty || _recognizedTexts.isEmpty) return;
    _setLoading(true);
    _errorMessage = null;
    try {
      final ocrDataBatch = _recognizedTexts.map((recognizedText) {
        final data = {
          'rawText': recognizedText.text,
          'imageSize': {
            'width': recognizedText.imageWidth,
            'height': recognizedText.imageHeight,
          },
          'lines': recognizedText.lines.map((line) => {
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
        if (customPrompt != null && customPrompt.isNotEmpty) {
          data['customPrompt'] = customPrompt;
        }
        return data;
      }).toList();

      _batchReceipts = await _receiptService.parseReceiptBatch(ocrDataBatch);

      if (_batchReceipts.isNotEmpty) {
        _receiptDetail = _batchReceipts.first;
      }
      _setStep(ReceiptScanStep.responsePreview);
    } catch (e, stack) {
      _errorMessage = e.toString();
      _stackTrace = stack.toString();
      _setStep(ReceiptScanStep.error);
    } finally {
      _setLoading(false);
    }
  }

  /// Upload gambar dan kirim rawText hasil OCR ke backend REST API (Gemini AI)
  Future<void> uploadToServer([String? customPrompt]) async {
    if (_selectedImage == null || _recognizedText == null) return;
    _setLoading(true);
    _errorMessage = null;
    try {
      final ocrData = {
        'rawText': _recognizedText!.text,
        'imageSize': {
          'width': _recognizedText!.imageWidth,
          'height': _recognizedText!.imageHeight,
        },
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

      if (customPrompt != null && customPrompt.isNotEmpty) {
        ocrData['customPrompt'] = customPrompt;
      }

      final receipts = await _receiptService.parseReceiptBatch([ocrData]);
      _receiptDetail = receipts.first;

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
  Future<void> confirmReceipt() async {
    if (_isBatchMode) {
      if (_batchReceipts.isNotEmpty && _selectedImages.isNotEmpty) {
        _setUploading(true);
        try {
          // Batch mode save sequence
          for (int i = 0; i < _batchReceipts.length; i++) {
             if (i < _selectedImages.length) {
                await _receiptService.saveReceipt(_batchReceipts[i], _selectedImages[i]);
             }
          }
          _setStep(ReceiptScanStep.confirmed);
        } catch (e) {
          _errorMessage = e.toString();
          _setStep(ReceiptScanStep.error);
        } finally {
          _setUploading(false);
        }
      }
    } else {
      if (_receiptDetail != null && _selectedImage != null) {
        _setUploading(true);
        try {
          await _receiptService.saveReceipt(_receiptDetail!, _selectedImage!);
          _setStep(ReceiptScanStep.confirmed);
        } catch (e) {
          _errorMessage = e.toString();
          _setStep(ReceiptScanStep.error);
        } finally {
          _setUploading(false);
        }
      }
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
