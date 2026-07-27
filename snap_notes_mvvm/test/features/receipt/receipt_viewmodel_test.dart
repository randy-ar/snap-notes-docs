import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:snap_notes_mvvm/features/receipt/models/receipt.dart';
import 'package:snap_notes_mvvm/features/receipt/models/receipt_service.dart';
import 'package:snap_notes_mvvm/features/receipt/models/recognized_text.dart' as local;
import 'package:snap_notes_mvvm/features/receipt/viewmodels/receipt_viewmodel.dart';

class FakeReceiptService implements ReceiptService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<File> rotateImageFile(File image, {int angle = 90}) async {
    return File('${image.path}_rotated_$angle.jpg');
  }

  @override
  Future<local.RecognizedText> extractTextFromImage(File image) async {
    return local.RecognizedText(
      text: 'Rotated OCR Text',
      lines: [],
      imageWidth: 1920,
      imageHeight: 1080,
    );
  }

  @override
  Future<List<local.RecognizedText>> extractTextFromImages(List<File> images) async {
    return images.map((_) => local.RecognizedText(
      text: 'Sample OCR Batch Text',
      lines: [],
      imageWidth: 1080,
      imageHeight: 1920,
    )).toList();
  }

  @override
  Future<List<Receipt>> parseBatchReceipt(
    List<File> images,
    List<local.RecognizedText> recognizedTexts,
    [String? customPrompt]
  ) async {
    return [
      Receipt(
        id: 'r1',
        storeName: 'Indomaret Batch',
        date: '2026-07-08',
        totalAmount: 10000,
        items: [],
      ),
      Receipt(
        id: 'r2',
        storeName: 'Alfamart Batch',
        date: '2026-07-08',
        totalAmount: 20000,
        items: [],
      ),
    ];
  }
}

void main() {
  group('ReceiptViewModel Batch Scan Test', () {
    late ReceiptViewModel viewModel;
    late FakeReceiptService fakeService;

    setUp(() {
      fakeService = FakeReceiptService();
      viewModel = ReceiptViewModel(receiptService: fakeService);
    });

    test('selectImages should update state to imageSelected and enable batchMode', () {
      final mockImages = [File('test1.jpg'), File('test2.jpg')];
      viewModel.selectImages(mockImages);

      expect(viewModel.selectedImages.length, 2);
      expect(viewModel.isBatchMode, isTrue);
      expect(viewModel.currentStep, ReceiptScanStep.imageSelected);
    });

    test('runBatchOCR should run OCR on multiple images and update step to batchOcrPreview', () async {
      final mockImages = [File('test1.jpg'), File('test2.jpg')];
      viewModel.selectImages(mockImages);

      await viewModel.runBatchOCR();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.recognizedTexts.length, 2);
      expect(viewModel.recognizedTexts.first.text, 'Sample OCR Batch Text');
      expect(viewModel.currentStep, ReceiptScanStep.batchOcrPreview);
    });

    test('uploadBatchToServer should upload batch data and update step to batchResponsePreview', () async {
      final mockImages = [File('test1.jpg'), File('test2.jpg')];
      viewModel.selectImages(mockImages);
      await viewModel.runBatchOCR();

      await viewModel.uploadBatchToServer('Konteks batch test');

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.batchReceipts.length, 2);
      expect(viewModel.batchReceipts.first.storeName, 'Indomaret Batch');
      expect(viewModel.batchReceipts[1].storeName, 'Alfamart Batch');
      expect(viewModel.currentStep, ReceiptScanStep.batchResponsePreview);
    });

    test('confirmReceipt should update step to confirmed when batchReceipts is not empty', () async {
      final mockImages = [File('test1.jpg'), File('test2.jpg')];
      viewModel.selectImages(mockImages);
      await viewModel.runBatchOCR();
      await viewModel.uploadBatchToServer();

      viewModel.confirmReceipt();

      expect(viewModel.currentStep, ReceiptScanStep.confirmed);
    });

    test('rotateImage should rotate selectedImage and run OCR when inside ocrPreview step', () async {
      viewModel.selectImage(File('test.jpg'));
      await viewModel.runOCR();

      await viewModel.rotateImage(angle: 90);

      expect(viewModel.selectedImage!.path, 'test.jpg_rotated_90.jpg');
      expect(viewModel.recognizedText!.text, 'Rotated OCR Text');
    });

    test('rotateBatchImage should rotate image at index and update recognizedTexts when inside batchOcrPreview step', () async {
      final mockImages = [File('test1.jpg'), File('test2.jpg')];
      viewModel.selectImages(mockImages);
      await viewModel.runBatchOCR();

      await viewModel.rotateBatchImage(0, angle: -90);

      expect(viewModel.selectedImages[0].path, 'test1.jpg_rotated_-90.jpg');
      expect(viewModel.recognizedTexts[0].text, 'Rotated OCR Text');
    });
  });
}
