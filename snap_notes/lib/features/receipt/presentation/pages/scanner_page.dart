import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'package:snap_notes/injection_container.dart';
import 'package:snap_notes/features/receipt/presentation/bloc/receipt_bloc.dart';
import 'package:snap_notes/features/receipt/presentation/bloc/receipt_event.dart';
import 'package:snap_notes/features/receipt/presentation/bloc/receipt_state.dart';
import 'package:snap_notes/features/receipt/domain/entities/receipt_entity.dart';
import 'package:snap_notes/features/receipt/domain/entities/recognized_text_entity.dart';
import 'package:snap_notes/features/receipt/presentation/pages/image_preview_page.dart';
import 'package:snap_notes/features/receipt/presentation/pages/text_recognition_preview_page.dart';
import 'package:snap_notes/features/receipt/presentation/pages/payload_preview_page.dart';
import 'package:snap_notes/features/receipt/presentation/pages/response_preview_page.dart';
import 'package:snap_notes/features/receipt/presentation/pages/upload_success_page.dart';
import 'package:snap_notes/features/receipt/presentation/pages/upload_failure_page.dart';

class ScannerPage extends StatelessWidget {
  const ScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ReceiptBloc>(),
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
      if (context.mounted) {
        context.read<ReceiptBloc>().add(ImageSelectedEvent(File(xFile.path)));
      }
    }
  }

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (context.mounted) {
        context.read<ReceiptBloc>().add(
          ImageSelectedEvent(File(pickedFile.path)),
        );
      }
    }
  }

  Future<void> _cropImage(BuildContext context, String imagePath) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imagePath,
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

    if (croppedFile != null && context.mounted) {
      context.read<ReceiptBloc>().add(ScanReceiptEvent(File(croppedFile.path)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      child: BlocConsumer<ReceiptBloc, ReceiptState>(
        listener: (context, state) {
          // No listener needed anymore, we handle errors in the builder
        },
        builder: (context, state) {
          if (state is ReceiptLoading) {
            if (state.image != null) {
              return _buildLoadingWithImagePreview(context, state.image!);
            }
            return const Center(child: CircularProgressIndicator());
          } else if (state is ReceiptImageSelected) {
            return ImagePreviewPage(image: state.image);
          } else if (state is ReceiptTextRecognizedPreview) {
            return TextRecognitionPreviewPage(
              image: state.image,
              recognizedText: state.recognizedText,
            );
          } else if (state is ReceiptPayloadPreview) {
            return PayloadPreviewPage(
              image: state.image,
              rawText: state.rawText,
              payload: state.payload,
              lines: state.lines,
              imageWidth: state.imageWidth,
              imageHeight: state.imageHeight,
            );
          } else if (state is ReceiptResponsePreview) {
            return ResponsePreviewPage(
              image: state.image,
              response: state.response,
              receipt: state.receipt,
            );
          } else if (state is ReceiptError) {
            return UploadFailurePage(
              message: state.message,
              stackTrace: state.stackTrace,
              serverResponse: state.serverResponse,
              statusCode: state.statusCode,
            );
          } else if (state is ReceiptParsed) {
            return _buildParsedReceiptView(context, state);
          } else if (state is ReceiptConfirmed) {
            // Show upload success page instead of simple view
            if (state.image != null) {
              return UploadSuccessPage(
                image: state.image!,
                receipt: state.receipt,
              );
            }
            // Fallback to simple view if no image available
            return _buildConfirmedReceiptView(context, state);
          }

          // Default: ReceiptCameraPreview
          return _buildCameraPreview(context);
        },
      ),
    );
  }

  Widget _buildLoadingWithImagePreview(BuildContext context, File image) {
    // Unused variables removed for cleaner code

    return Scaffold(
      headers: [
        AppBar(
          title: const Text('Mengupload ke Server'),
        ),
      ],
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image with bounding boxes
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          image,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.black.withValues(alpha: 0.3),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const CircularProgressIndicator(),
                                const Gap(16),
                                Text(
                'Mengupload ke server...',
                style: Theme.of(context).typography.large.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Card(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                        children: [
                          Icon(LucideIcons.info, color: Theme.of(context).colorScheme.primary),
                          const Gap(12),
                          const Expanded(
                            child: Text('Mohon tunggu, sedang memproses gambar struk Anda...'),
                          ),
                        ],
                      ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview(BuildContext context) {
    if (!_isCameraInitialized || _cameraController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        // Camera Preview with Black Background
        Positioned.fill(
          child: Container(
            color: const Color(0xFF000000),
            child: Center(
              child: AspectRatio(
                aspectRatio: 1 / _cameraController!.value.aspectRatio,
                child: CameraPreview(_cameraController!),
              ),
            ),
          ),
        ),

        // Header
        Positioned(
          top: 48,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Scan Struk',
                style: Theme.of(context).typography.large.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Placeholder to balance the row
              const SizedBox(width: 60),

              // Capture Button
              GestureDetector(
                onTap: () => _captureImage(context),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFFFFFFF),
                      width: 4,
                    ),
                    color: const Color(0x88000000),
                  ),
                  child: const Center(
                    child: Icon(
                      LucideIcons.camera,
                      color: Color(0xFFFFFFFF),
                      size: 32,
                    ),
                  ),
                ),
              ),

              // Gallery Button
              GestureDetector(
                onTap: () => _pickImage(context),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withValues(alpha: 0.5),
                  ),
                  child: const Center(
                    child: Icon(Icons.image, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildParsedReceiptView(BuildContext context, ReceiptParsed state) {
    final receipt = state.receipt;

    return Scaffold(
      headers: [
        AppBar(
          title: const Text('Data Struk'),
        ),
      ],
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Preview
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      state.image,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Store Info
                  _buildInfoRow('Toko', receipt.storeName),
                  _buildInfoRow('Tanggal', receipt.date),
                  _buildInfoRow('Total', 'Rp ${receipt.totalAmount.toStringAsFixed(0)}'),
                  const SizedBox(height: 16),

                  // Items List
                  const Text('Items:').small().semiBold(),
                  const Gap(12),
                  ...receipt.items.map((item) => _buildItemRow(context, item)),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    onPressed: () => _cropImage(context, state.image.path),
                    child: const Text('Crop Ulang'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: PrimaryButton(
                    onPressed: () => context.read<ReceiptBloc>().add(ConfirmReceiptEvent()),
                    child: const Text('Konfirmasi'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildItemRow(BuildContext context, ReceiptItemEntity item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Card(
        padding: const EdgeInsets.all(12.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.name).small().semiBold(),
              const Gap(8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${item.quantity} x Rp ${item.price.toStringAsFixed(0)}').small().muted(),
                  Text('Rp ${item.totalPrice.toStringAsFixed(0)}').small().semiBold(),
                ],
              ),
            ],
          ),
      ),
    );
  }

  Widget _buildConfirmedReceiptView(BuildContext context, ReceiptConfirmed state) {
    final receipt = state.receipt;

    return Scaffold(
      headers: [AppBar(title: const Text('Struk Tersimpan'))],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.primary,
              size: 64,
            ),
            const Gap(24),
            Text(receipt.storeName).large().bold(),
            const Gap(12),
            Text('Total: Rp ${receipt.totalAmount.toStringAsFixed(0)}').p(),
            const Gap(8),
            Text('${receipt.items.length} items tercatat').small().muted(),
            const Gap(32),
            PrimaryButton(
              onPressed: () => context.read<ReceiptBloc>().add(StartCameraEvent()),
              child: const Text('Scan Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

class BoundingBoxPainter extends CustomPainter {
  final List<TextLineEntity> lines;
  final double imageWidth;
  final double imageHeight;
  final Color color;

  BoundingBoxPainter({
    required this.lines,
    required this.imageWidth,
    required this.imageHeight,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (imageWidth == 0 || imageHeight == 0) return;

    final paint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    final scaleX = size.width / imageWidth;
    final scaleY = size.height / imageHeight;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final rect = Rect.fromLTRB(
        line.boundingBox.left * scaleX,
        line.boundingBox.top * scaleY,
        line.boundingBox.right * scaleX,
        line.boundingBox.bottom * scaleY,
      );

      canvas.drawRect(rect, fillPaint);
      canvas.drawRect(rect, paint);

      final textPainter = TextPainter(
        text: TextSpan(
          text: '${i + 1}',
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(rect.left, rect.top - 16));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

