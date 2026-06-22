import 'dart:io';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:snap_notes_mvvm/core/di/injection.dart';
import 'package:snap_notes_mvvm/features/receipt/viewmodels/receipt_viewmodel.dart';
import 'package:snap_notes_mvvm/features/receipt/views/pages/text_recognition_preview_page.dart';
import 'package:snap_notes_mvvm/features/receipt/views/pages/response_preview_page.dart';
import 'package:snap_notes_mvvm/features/receipt/views/pages/upload_success_page.dart';
import 'package:snap_notes_mvvm/features/receipt/views/pages/upload_failure_page.dart';
import 'package:snap_notes_mvvm/features/receipt/views/widgets/scan_animation_overlay.dart';

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
  final StepperController _stepperController = StepperController();

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
            CropAspectRatioPreset.original,
          ],
        ),
        IOSUiSettings(
          title: 'Crop Receipt',
          aspectRatioPickerButtonHidden: true,
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
          ],
        ),
      ],
    );

    if (croppedFile != null && mounted) {
      final viewModel = context.read<ReceiptViewModel>();
      viewModel.selectImage(File(croppedFile.path));
      viewModel.runOCR();
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ReceiptViewModel>();

    if (viewModel.isLoading && viewModel.currentStep == ReceiptScanStep.imageSelected) {
      return Scaffold(
        headers: [
          AppBar(
            title: const Text('Menjalankan OCR lokal (ML Kit)...'),
          ),
        ],
        child: Stack(
          children: [
            if (viewModel.selectedImage != null)
              Center(
                child: Image.file(
                  viewModel.selectedImage!,
                  fit: BoxFit.contain,
                ),
              ),
            const Positioned.fill(
              child: ScanAnimationOverlay(text: 'Menjalankan OCR lokal (ML Kit)...'),
            ),
          ],
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
              const Text('Mengirim dan memproses struk dengan Gemini AI...'),
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

    // Pemetaan alur ke index stepper (0-3)
    int mappedIndex = 0;
    int? errorStepIndex;

    switch (viewModel.currentStep) {
      case ReceiptScanStep.camera:
      case ReceiptScanStep.imageSelected:
        mappedIndex = 0;
        break;
      case ReceiptScanStep.ocrPreview:
        mappedIndex = 1;
        break;
      case ReceiptScanStep.payloadPreview:
      case ReceiptScanStep.responsePreview:
        mappedIndex = 2;
        break;
      case ReceiptScanStep.confirmed:
        mappedIndex = 3; // Tetap di index 3 agar merender UploadSuccessPage!
        break;
      case ReceiptScanStep.error:
        // Jika error, tentukan index langkah aktif dan langkah mana yang failed
        if (viewModel.receiptDetail == null) {
          mappedIndex = 2;
          errorStepIndex = 2;
        } else {
          mappedIndex = 3;
          errorStepIndex = 3;
        }
        break;
    }

    // Sinkronisasi stepper secara aman di frame berikutnya
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Bersihkan status dari langkah lain terlebih dahulu
      for (int i = 0; i < 4; i++) {
        if (errorStepIndex == null || errorStepIndex != i) {
          _stepperController.setStatus(i, null);
        }
      }
      
      if (errorStepIndex != null) {
        _stepperController.setStatus(errorStepIndex, StepState.failed);
      }
      
      if (_stepperController.value.currentStep != mappedIndex) {
        _stepperController.jumpToStep(mappedIndex);
      }
    });

    return Scaffold(
      headers: [
        AppBar(
          title: const Text('Scan Struk'),
          leading: [
            IconButton.ghost(
              onPressed: () => viewModel.cancelScan(),
              icon: const Icon(LucideIcons.arrowLeft),
            ),
          ],
        ),
      ],
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stepper(
                controller: _stepperController,
                direction: Axis.horizontal,
                variant: StepVariant.circleAlt,
                steps: [
                  Step(
                    title: const Text('Ambil Foto'),
                    contentBuilder: (context) => _buildStepContent(0, viewModel),
                  ),
                  Step(
                    title: const Text('Scan Foto'),
                    contentBuilder: (context) => _buildStepContent(1, viewModel),
                  ),
                  Step(
                    title: const Text('Review AI'),
                    contentBuilder: (context) => _buildStepContent(2, viewModel),
                  ),
                  Step(
                    title: const Text('Simpan Struk'),
                    icon: viewModel.currentStep == ReceiptScanStep.confirmed
                        ? const StepNumber(icon: Icon(LucideIcons.check))
                        : null,
                    contentBuilder: (context) => _buildStepContent(3, viewModel),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent(int stepIndex, ReceiptViewModel viewModel) {
    if (viewModel.currentStep == ReceiptScanStep.error) {
      final isOcrError = viewModel.receiptDetail == null;
      if ((isOcrError && stepIndex == 2) || (!isOcrError && stepIndex == 3)) {
        return UploadFailurePage(
          message: viewModel.errorMessage ?? 'Terjadi kesalahan sistem',
          stackTrace: viewModel.stackTrace,
          serverResponse: viewModel.serverResponse,
          statusCode: viewModel.statusCode,
          useScaffold: false,
        );
      }
    }

    switch (stepIndex) {
      case 0:
        if (viewModel.currentStep == ReceiptScanStep.imageSelected) {
          if (viewModel.selectedImage == null) return const SizedBox.shrink();
          return _buildImageSelectedPreview(context, viewModel, useScaffold: false);
        }
        return _buildCameraPreview(context, useScaffold: false);
      case 1:
        if (viewModel.selectedImage == null) {
          return const SizedBox.shrink();
        }
        return TextRecognitionPreviewPage(
          image: viewModel.selectedImage!,
          recognizedText: viewModel.recognizedText,
          useScaffold: false,
        );
      case 2:
        if (viewModel.selectedImage == null || viewModel.receiptDetail == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return ResponsePreviewPage(
          image: viewModel.selectedImage!,
          receipt: viewModel.receiptDetail!,
          useScaffold: false,
        );
      case 3:
        if (viewModel.selectedImage == null || viewModel.receiptDetail == null) {
          return const SizedBox.shrink();
        }
        return UploadSuccessPage(
          image: viewModel.selectedImage!,
          receipt: viewModel.receiptDetail!,
          useScaffold: false,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildCameraPreview(BuildContext context, {bool useScaffold = true}) {
    if (!_isCameraInitialized || _cameraController == null) {
      final loadingWidget = const Center(child: CircularProgressIndicator());
      return useScaffold ? Scaffold(child: loadingWidget) : loadingWidget;
    }

    final cameraContent = Stack(
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
    );

    if (!useScaffold) {
      return cameraContent;
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
        child: cameraContent,
      ),
    );
  }

  Widget _buildImageSelectedPreview(BuildContext context, ReceiptViewModel viewModel, {bool useScaffold = true}) {
    final previewContent = Column(
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
    );

    if (!useScaffold) {
      return previewContent;
    }

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
      child: previewContent,
    );
  }
}
