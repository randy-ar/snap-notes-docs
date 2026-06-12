import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:snap_notes/features/receipt/presentation/bloc/receipt_bloc.dart';
import 'package:snap_notes/features/receipt/presentation/bloc/receipt_event.dart';

class ImagePreviewPage extends StatelessWidget {
  final File image;

  const ImagePreviewPage({super.key, required this.image});

  Future<void> _cropImage(BuildContext context) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: image.path,
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
      context.read<ReceiptBloc>().add(CropImageEvent(File(croppedFile.path)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      headers: [
        AppBar(
          title: const Text('Preview Gambar'),
          leading: [
            IconButton.ghost(
              onPressed: () => context.read<ReceiptBloc>().add(StartCameraEvent()),
              icon: const Icon(LucideIcons.arrowLeft),
            ),
          ],
        ),
      ],
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      image,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const Gap(16),
                  const Text('Gambar siap untuk diproses').large(),
                  const Gap(8),
                  const Text('Anda dapat crop gambar untuk memfokuskan area struk').small().muted(),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SecondaryButton(
                  onPressed: () => _cropImage(context),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.crop),
                      Gap(8),
                      Text('Crop Gambar'),
                    ],
                  ),
                ),
                const Gap(12),
                PrimaryButton(
                  onPressed: () => context.read<ReceiptBloc>().add(
                    ProceedToScanEvent(image),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.scan),
                      Gap(8),
                      Text('Lanjut Scan'),
                    ],
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
