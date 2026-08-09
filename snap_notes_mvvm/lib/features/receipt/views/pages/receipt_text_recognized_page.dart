import 'dart:io';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:snap_notes_mvvm/features/receipt/models/recognized_text.dart';
import 'package:snap_notes_mvvm/features/receipt/viewmodels/receipt_viewmodel.dart';
import 'package:snap_notes_mvvm/features/receipt/views/pages/receipt_parsed_page.dart';
import 'package:snap_notes_mvvm/features/receipt/views/widgets/scan_animation_overlay.dart';

class ReceiptTextRecognizedPage extends StatefulWidget {
  final File? image;
  final List<File>? images;
  final RecognizedText? recognizedText;
  final List<RecognizedText>? recognizedTexts;
  final bool isBatchMode;
  final bool useScaffold;

  const ReceiptTextRecognizedPage({
    super.key,
    this.image,
    this.images,
    this.recognizedText,
    this.recognizedTexts,
    required this.isBatchMode,
    this.useScaffold = true,
  });

  @override
  State<ReceiptTextRecognizedPage> createState() =>
      _ReceiptTextRecognizedPageState();
}

class _ReceiptTextRecognizedPageState extends State<ReceiptTextRecognizedPage> {
  final StepperController _stepperController = StepperController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _stepperController.jumpToStep(1); // Jump to "Scan Foto" step
    });
  }

  void submitAnalisis() {
    final viewModel = context.read<ReceiptViewModel>();
    // Backend returns parsed JSON from Gemini API, saving it to viewModel state.
    // We don't await because we want the loading overlay to show.
    viewModel.uploadToServer(null).then((_) {
      if (mounted && viewModel.receiptDetail != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChangeNotifierProvider.value(
              value: viewModel,
              child: ReceiptParsedPage(
                isBatchMode: false,
                image: widget.image!,
                receipt: viewModel.receiptDetail!,
              ),
            ),
          ),
        );
      }
    });
  }

  void submitBatchAnalisis() {
    final viewModel = context.read<ReceiptViewModel>();
    viewModel.uploadBatchToServer(null).then((_) {
      if (mounted && viewModel.batchReceipts.isNotEmpty) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChangeNotifierProvider.value(
              value: viewModel,
              child: ReceiptParsedPage(
                isBatchMode: true,
                images: widget.images,
                receipts: viewModel.batchReceipts,
              ),
            ),
          ),
        );
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ReceiptViewModel>();

    final mainContent = widget.isBatchMode
        ? _buildBatchContent(context, viewModel)
        : _buildSingleContent(context, viewModel);

    if (!widget.useScaffold) {
      return mainContent;
    }

    return Scaffold(
      headers: [
        AppBar(
          title: const Text('Scan Struk'),
          leading: [
            if (!widget.isBatchMode)
              IconButton.ghost(
                onPressed: () => Navigator.of(context).pop(),
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
                  const Step(
                    title: Text('Ambil Foto'),
                    contentBuilder: _buildEmptyStepContent,
                  ),
                  Step(
                    title: const Text('Scan Foto'),
                    contentBuilder: (context) => mainContent,
                  ),
                  const Step(
                    title: Text('Review AI'),
                    contentBuilder: _buildEmptyStepContent,
                  ),
                  const Step(
                    title: Text('Simpan Struk'),
                    contentBuilder: _buildEmptyStepContent,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildEmptyStepContent(BuildContext context) => const SizedBox.shrink();

  // ---------------------------------------------------------------------------
  // Single mode
  // ---------------------------------------------------------------------------

  Widget _buildSingleContent(BuildContext context, ReceiptViewModel viewModel) {
    final hasNoText = viewModel.recognizedText == null || viewModel.recognizedText!.text.trim().isEmpty;

    return Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Preview OCR').medium().semiBold(),
                  if (hasNoText && !viewModel.isLoading)
                     IconButton.destructive(
                       onPressed: () {
                         Navigator.of(context).pop();
                       },
                       icon: const Icon(LucideIcons.trash),
                     )
                ],
              ),
            ),
            if (hasNoText && !viewModel.isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: _buildWarningBanner(
                  context,
                  title: 'Teks tidak terdeteksi',
                  message: 'OCR tidak dapat menemukan teks pada gambar ini. Pastikan gambar jelas dan tidak buram.',
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Stack(
                    children: [
                      if (widget.image != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            widget.image!,
                            fit: BoxFit.contain,
                          ),
                        ),
                      if (viewModel.recognizedText != null && !hasNoText)
                        Positioned.fill(
                          child: CustomPaint(
                            painter: BoundingBoxPainter(
                              lines: viewModel.recognizedText!.lines,
                              imageWidth: viewModel.recognizedText!.imageWidth,
                              imageHeight: viewModel.recognizedText!.imageHeight,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: PrimaryButton(
                onPressed: (viewModel.isLoading || hasNoText) ? null : () => submitAnalisis(),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.check, size: 18),
                    Gap(8),
                    Text('Selanjutnya'),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (viewModel.isLoading)
          Positioned.fill(
            child: ScanAnimationOverlay(
              text: viewModel.recognizedText == null
                  ? 'Menjalankan OCR lokal (ML Kit)...'
                  : 'Menganalisis dengan Gemini AI...',
            ),
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Batch mode
  // ---------------------------------------------------------------------------

  Widget _buildBatchContent(BuildContext context, ReceiptViewModel viewModel) {
    final images = viewModel.selectedImages.isNotEmpty ? viewModel.selectedImages : widget.images;
    if (images == null || images.isEmpty) {
      return const Center(child: Text('Tidak ada gambar'));
    }

    if (_currentIndex >= images.length) {
      _currentIndex = images.length - 1;
    }

    final currentImg = images[_currentIndex];
    final currentRt = viewModel.recognizedTexts.length > _currentIndex
        ? viewModel.recognizedTexts[_currentIndex]
        : null;

    final hasNoText = currentRt == null || currentRt.text.trim().isEmpty;
    final allImagesHaveNoText = viewModel.recognizedTexts.every((rt) => rt.text.trim().isEmpty);

    return Stack(
      children: [
        Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Gambar ${_currentIndex + 1} dari ${images.length}')
                      .medium()
                      .semiBold(),
                  Row(
                    children: [
                      if (hasNoText && !viewModel.isLoading)
                        IconButton.destructive(
                          onPressed: () {
                             if (images.length == 1) {
                               Navigator.of(context).pop();
                             } else {
                               viewModel.removeBatchImage(_currentIndex);
                             }
                          },
                          icon: const Icon(LucideIcons.trash),
                        ),
                      const Gap(8),
                      OutlineButton(
                        onPressed: _currentIndex > 0
                            ? () => setState(() => _currentIndex--)
                            : null,
                        size: ButtonSize.small,
                        child: const Icon(LucideIcons.chevronLeft, size: 16),
                      ),
                      const Gap(8),
                      OutlineButton(
                        onPressed: _currentIndex < images.length - 1
                            ? () => setState(() => _currentIndex++)
                            : null,
                        size: ButtonSize.small,
                        child: const Icon(LucideIcons.chevronRight, size: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (hasNoText && !viewModel.isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: _buildWarningBanner(
                  context,
                  title: 'Teks tidak terdeteksi',
                  message: 'OCR tidak dapat menemukan teks pada gambar ini. Hapus foto ini dari batch.',
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          currentImg,
                          fit: BoxFit.contain,
                        ),
                      ),
                      if (currentRt != null && !hasNoText)
                        Positioned.fill(
                          child: CustomPaint(
                            painter: BoundingBoxPainter(
                              lines: currentRt.lines,
                              imageWidth: currentRt.imageWidth,
                              imageHeight: currentRt.imageHeight,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: PrimaryButton(
                onPressed: (viewModel.isLoading || allImagesHaveNoText)
                    ? null
                    : () => submitBatchAnalisis(),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.check, size: 18),
                    Gap(8),
                    Text('Selanjutnya'),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (viewModel.isLoading)
          const Positioned.fill(
            child: ScanAnimationOverlay(
                text: 'Menganalisis batch struk dengan Gemini AI...'),
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Widget _buildWarningBanner(BuildContext context, {required String title, required String message}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.destructive.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: Theme.of(context).colorScheme.destructive.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded,
              color: Theme.of(context).colorScheme.destructive, size: 32),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).typography.base.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.destructive,
                      ),
                ),
                Text(message).xSmall().muted(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// BoundingBoxPainter
// -----------------------------------------------------------------------------

class BoundingBoxPainter extends CustomPainter {
  final List<TextLine> lines;
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

      // Gambar filled rectangle
      canvas.drawRect(rect, fillPaint);

      // Gambar border
      canvas.drawRect(rect, paint);

      // Gambar nomor baris
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
