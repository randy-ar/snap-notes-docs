import 'dart:io';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:snap_notes_mvvm/core/di/injection.dart';
import 'package:snap_notes_mvvm/features/receipt/viewmodels/receipt_viewmodel.dart';
import 'package:snap_notes_mvvm/features/receipt/views/pages/text_recognition_preview_page.dart';
import 'package:snap_notes_mvvm/features/receipt/views/pages/payload_preview_page.dart';
import 'package:snap_notes_mvvm/features/receipt/views/pages/response_preview_page.dart';
import 'package:snap_notes_mvvm/features/receipt/views/pages/upload_success_page.dart';
import 'package:snap_notes_mvvm/features/receipt/views/pages/upload_failure_page.dart';

class ScannerPage extends StatelessWidget {
  const ScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<ReceiptViewModel>()..startCamera(),
      child: const ScannerView(),
    );
  }
}

class ScannerView extends StatefulWidget {
  const ScannerView({super.key});

  @override
  State<ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      _cameraController = CameraController(
        _cameras![0],
        ResolutionPreset.max,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _captureImage(BuildContext context) async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      final xFile = await _cameraController!.takePicture();
      if (mounted) {
        _cropImage(context, File(xFile.path));
      }
    }
  }

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null && mounted) {
      _cropImage(context, File(pickedFile.path));
    }
  }

  Future<void> _cropImage(BuildContext context, File imageFile) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Receipt',
          toolbarColor: const Color(0xFF000000),
          toolbarWidgetColor: const Color(0xFFFFFFFF),
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
          ],
        ),
        IOSUiSettings(
          title: 'Crop Receipt',
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
          ],
        ),
      ],
    );

    if (croppedFile != null && mounted) {
      context.read<ReceiptViewModel>().selectImage(File(croppedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ReceiptViewModel>();

    if (viewModel.isLoading && viewModel.currentStep == ReceiptScanStep.imageSelected) {
      return const Scaffold(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              Gap(16),
              Text('Menjalankan OCR lokal (ML Kit)...'),
            ],
          ),
        ),
      );
    }

    if (viewModel.isLoading && viewModel.currentStep == ReceiptScanStep.payloadPreview) {
      return Scaffold(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const Gap(16),
              Text('Mengirim dan memproses struk dengan Gemini AI...'),
              if (viewModel.selectedImage != null) ...[
                const Gap(24),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    viewModel.selectedImage!,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    switch (viewModel.currentStep) {
      case ReceiptScanStep.camera:
        return _buildCameraPreview(context);
      case ReceiptScanStep.imageSelected:
        return _buildImageSelectedPreview(context, viewModel);
      case ReceiptScanStep.ocrPreview:
        return TextRecognitionPreviewPage(
          image: viewModel.selectedImage!,
          recognizedText: viewModel.recognizedText!,
        );
      case ReceiptScanStep.payloadPreview:
        return PayloadPreviewPage(
          image: viewModel.selectedImage!,
          rawText: viewModel.recognizedText!.text,
          payload: viewModel.payload!,
        );
      case ReceiptScanStep.responsePreview:
        return ResponsePreviewPage(
          image: viewModel.selectedImage!,
          receipt: viewModel.receiptDetail!,
        );
      case ReceiptScanStep.confirmed:
        return UploadSuccessPage(
          image: viewModel.selectedImage!,
          receipt: viewModel.receiptDetail!,
        );
      case ReceiptScanStep.error:
        return UploadFailurePage(
          message: viewModel.errorMessage ?? 'Terjadi kesalahan sistem',
          stackTrace: viewModel.stackTrace,
          serverResponse: viewModel.serverResponse,
          statusCode: viewModel.statusCode,
        );
    }
  }

  Widget _buildCameraPreview(BuildContext context) {
    if (!_isCameraInitialized || _cameraController == null) {
      return const Scaffold(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      headers: [
        AppBar(
          title: const Text('Scan Struk'),
          leading: [
            IconButton.ghost(
              icon: const Icon(LucideIcons.arrowLeft),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ],
      child: SafeArea(
        child: Stack(
          children: [
            // Camera preview
            Positioned.fill(
              child: Container(
                color: Colors.black,
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1 / _cameraController!.value.aspectRatio,
                    child: CameraPreview(_cameraController!),
                  ),
                ),
              ),
            ),
            // Controls
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton.ghost(
                    onPressed: () => _pickImage(context),
                    icon: const Icon(LucideIcons.image, color: Colors.white),
                  ),
                  PrimaryButton(
                    shape: ButtonShape.circle,
                    size: ButtonSize.large,
                    onPressed: () => _captureImage(context),
                    child: const Icon(LucideIcons.camera),
                  ),
                  const SizedBox(width: 48), // Spacer
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSelectedPreview(BuildContext context, ReceiptViewModel viewModel) {
    return Scaffold(
      headers: [
        AppBar(
          title: const Text('Preview Struk'),
          leading: [
            IconButton.ghost(
              onPressed: () => viewModel.cancelScan(),
              icon: const Icon(LucideIcons.arrowLeft),
            ),
          ],
        ),
      ],
      child: Column(
        children: [
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.muted,
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    viewModel.selectedImage!,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    onPressed: () => _cropImage(context, viewModel.selectedImage!),
                    child: const Text('Crop Ulang'),
                  ),
                ),
                const Gap(16),
                Expanded(
                  child: PrimaryButton(
                    onPressed: () => viewModel.runOCR(),
                    child: const Text('Mulai OCR'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
