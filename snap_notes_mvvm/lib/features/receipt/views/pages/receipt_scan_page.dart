import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'package:snap_notes_mvvm/core/di/injection.dart';
import 'package:snap_notes_mvvm/features/receipt/viewmodels/receipt_viewmodel.dart';
import 'package:snap_notes_mvvm/features/receipt/views/pages/receipt_text_recognized_page.dart';

class ReceiptScanPage extends StatelessWidget {
  const ReceiptScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<ReceiptViewModel>()..startCamera(),
      child: const ReceiptScanView(),
    );
  }
}

class ReceiptScanView extends StatefulWidget {
  const ReceiptScanView({super.key});

  @override
  State<ReceiptScanView> createState() => _ReceiptScanViewState();
}

class _ReceiptScanViewState extends State<ReceiptScanView> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  final shadcn.StepperController _stepperController = shadcn.StepperController();

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  Future<void> initCamera() async {
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
    _stepperController.dispose();
    super.dispose();
  }

  // Dispose camera before navigating away to avoid resource leak
  Future<void> _disposeCamera() async {
    final controller = _cameraController;
    if (controller == null) return;

    if (mounted) {
      setState(() {
        _isCameraInitialized = false;
        _cameraController = null;
      });
    } else {
      _cameraController = null;
    }
    await controller.dispose();
  }

  Future<void> captureImage() async {
    final controller = _cameraController;
    if (controller != null && controller.value.isInitialized) {
      final xFile = await controller.takePicture();
      if (mounted) {
        await _disposeCamera();
        cropImage(File(xFile.path));
      }
    }
  }



  Future<void> pickMultipleImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles.isNotEmpty && mounted) {
      await _disposeCamera();
      await processBatchCrop(pickedFiles.map((pf) => File(pf.path)).toList());
    }
  }

  Future<void> processBatchCrop(List<File> initialFiles) async {
    List<File> processedFiles = [];

    for (var file in initialFiles) {
      if (!mounted) return;

      final croppedFile = await ImageCropper().cropImage(
        sourcePath: file.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Struk ${processedFiles.length + 1} / ${initialFiles.length}',
            toolbarColor: const Color(0xFF000000),
            toolbarWidgetColor: const Color(0xFFFFFFFF),
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
            ],
          ),
          IOSUiSettings(
            title: 'Crop Struk ${processedFiles.length + 1} / ${initialFiles.length}',
            aspectRatioPickerButtonHidden: true,
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
            ],
          ),
        ],
      );

      if (croppedFile != null) {
        processedFiles.add(File(croppedFile.path));
      }
    }

    if (processedFiles.isNotEmpty && mounted) {
      final viewModel = context.read<ReceiptViewModel>();

      if (processedFiles.length == 1) {
        viewModel.selectImage(processedFiles.first);
        viewModel.runOCR();
      } else {
        await viewModel.processBatchCrop(processedFiles);
      }

      if (mounted) {
         await Navigator.of(context).push(
           MaterialPageRoute(
             builder: (context) => ChangeNotifierProvider.value(
               value: viewModel,
               child: ReceiptTextRecognizedPage(
                 isBatchMode: processedFiles.length > 1,
                 image: processedFiles.length == 1 ? processedFiles.first : null,
                 images: processedFiles.length > 1 ? processedFiles : null,
               ),
             ),
           ),
         );
         if (mounted) await initCamera();
      }
    } else {
      if (mounted) await initCamera();
    }
  }

  Future<void> cropImage(File imageFile) async {
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

    if (croppedFile != null) {
      final viewModel = context.read<ReceiptViewModel>();
      viewModel.selectImage(File(croppedFile.path));
      viewModel.runOCR();
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider.value(
            value: viewModel,
            child: ReceiptTextRecognizedPage(
              isBatchMode: false,
              image: File(croppedFile.path),
            ),
          ),
        ),
      );
      if (mounted) await initCamera();
    } else {
      await initCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized || _cameraController == null) {
      return const shadcn.Scaffold(child: Center(child: shadcn.CircularProgressIndicator()));
    }

    final viewModel = context.watch<ReceiptViewModel>();

    return shadcn.Scaffold(
      headers: [
        shadcn.AppBar(
          title: const Text('Scan Struk'),
          leading: [
            shadcn.IconButton.ghost(
              icon: const Icon(shadcn.LucideIcons.arrowLeft),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ],
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: shadcn.Stepper(
                controller: _stepperController,
                direction: Axis.horizontal,
                variant: shadcn.StepVariant.circleAlt,
                steps: [
                  shadcn.Step(
                    title: const Text('Ambil Foto'),
                    contentBuilder: (context) => _buildCameraPreview(context),
                  ),
                  shadcn.Step(
                    title: const Text('Scan Foto'),
                    contentBuilder: (context) => const SizedBox.shrink(),
                  ),
                  shadcn.Step(
                    title: const Text('Review AI'),
                    contentBuilder: (context) => const SizedBox.shrink(),
                  ),
                  shadcn.Step(
                    title: const Text('Simpan Struk'),
                    icon: viewModel.currentStep == ReceiptScanStep.confirmed
                        ? const shadcn.StepNumber(icon: Icon(shadcn.LucideIcons.check))
                        : null,
                    contentBuilder: (context) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview(BuildContext context) {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) {
      return const Center(child: shadcn.CircularProgressIndicator());
    }

    return Stack(
      children: [
        // Camera preview
        Positioned.fill(
          child: Container(
            color: Colors.black,
            child: Center(
              child: AspectRatio(
                aspectRatio: 1 / controller.value.aspectRatio,
                child: CameraPreview(controller),
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
                shadcn.IconButton.ghost(
                onPressed: pickMultipleImages,
                icon: const Icon(shadcn.LucideIcons.image, color: Colors.white),
              ),
              shadcn.PrimaryButton(
                shape: shadcn.ButtonShape.circle,
                size: shadcn.ButtonSize.large,
                onPressed: captureImage,
                child: const Icon(shadcn.LucideIcons.camera),
              ),
              const SizedBox(width: 48), // Placeholder untuk menyeimbangkan layout
            ],
          ),
        ),
      ],
    );
  }
}
