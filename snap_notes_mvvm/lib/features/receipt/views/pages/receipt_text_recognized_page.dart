import 'dart:io';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:snap_notes_mvvm/features/receipt/models/recognized_text.dart';
import 'package:snap_notes_mvvm/features/receipt/viewmodels/receipt_viewmodel.dart';
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
  String? _selectedCategory;
  String? _customPrompt;
  int _currentIndex = 0;

  final List<String> categories = [
    'Makanan', 'Minuman', 'Sembako', 'Transportasi', 'Komunikasi',
    'Edukasi', 'Perawatan', 'Pakaian', 'Hiburan', 'Kesehatan',
    'Elektronik', 'Otomotif', 'Lainnya',
  ];

  void showKonteksDrawer() {
    final promptController = TextEditingController(text: _customPrompt);
    String? tempCategory = _selectedCategory;

    openDrawer(
      context: context,
      position: OverlayPosition.bottom,
      builder: (drawerContext) {
        return StatefulBuilder(
          builder: (drawerContext, setSheetState) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(widget.isBatchMode
                          ? 'Beri Konteks AI Batch'
                          : 'Beri Konteks AI')
                      .large()
                      .semiBold(),
                  const Gap(8),
                  Text(widget.isBatchMode
                          ? 'Berikan instruksi tambahan sebelum AI menganalisis seluruh gambar struk sekaligus.'
                          : 'Pilih kategori dan/atau berikan instruksi tambahan sebelum AI menganalisis struk.')
                      .muted(),
                  const Gap(16),

                  // Kategori hanya ditampilkan di single mode
                  if (!widget.isBatchMode) ...[
                    const Text('Kategori (Opsional)').medium(),
                    const Gap(4),
                    Select<String>(
                      itemBuilder: (context, item) => Text(item),
                      popup: SelectPopup.builder(
                        searchPlaceholder: const Text('Cari kategori'),
                        builder: (context, searchQuery) {
                          final filtered = searchQuery == null
                              ? categories
                              : categories
                                  .where((c) => c
                                      .toLowerCase()
                                      .contains(searchQuery.toLowerCase()))
                                  .toList();
                          return SelectItemList(
                            children: [
                              for (final c in filtered)
                                SelectItemButton(value: c, child: Text(c))
                            ],
                          );
                        },
                      ),
                      onChanged: (value) {
                        setSheetState(() {
                          tempCategory = value;
                        });
                      },
                      value: tempCategory,
                      placeholder: const Text('Pilih Kategori'),
                    ),
                    const Gap(16),
                  ],

                  const Text('Instruksi Tambahan (Opsional)').medium(),
                  const Gap(4),
                  TextField(
                    controller: promptController,
                    placeholder: Text(widget.isBatchMode
                        ? 'Contoh: "Semua struk ini adalah biaya konsumsi rapat kantor"'
                        : 'Contoh: "Ini adalah struk tagihan internet bulanan"'),
                    minLines: 3,
                    maxLines: 5,
                  ),
                  const Gap(24),

                  PrimaryButton(
                    onPressed: () {
                      setState(() {
                        _selectedCategory = tempCategory;
                        _customPrompt = promptController.text;
                      });
                      closeOverlay(drawerContext);
                    },
                    child: const Text('Simpan Konteks'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void submitAnalisis() {
    final viewModel = context.read<ReceiptViewModel>();
    String combinedPrompt = '';
    if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
      combinedPrompt += 'Kategori yang disarankan: $_selectedCategory.\n';
    }
    if (_customPrompt != null && _customPrompt!.isNotEmpty) {
      combinedPrompt += _customPrompt!;
    }
    viewModel
        .uploadToServer(combinedPrompt.isEmpty ? null : combinedPrompt.trim());
  }

  void submitBatchAnalisis() {
    final viewModel = context.read<ReceiptViewModel>();
    viewModel.uploadBatchToServer(_customPrompt);
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
          title: Text(
              widget.isBatchMode ? 'Preview OCR Batch' : 'Hasil Deteksi Teks'),
          leading: [
            if (!widget.isBatchMode)
              IconButton.ghost(
                onPressed: () => viewModel.cancelScan(),
                icon: const Icon(LucideIcons.arrowLeft),
              ),
          ],
        ),
      ],
      child: mainContent,
    );
  }

  // ---------------------------------------------------------------------------
  // Single mode
  // ---------------------------------------------------------------------------

  Widget _buildSingleContent(BuildContext context, ReceiptViewModel viewModel) {
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
                  const Text('Preview OCR').medium().semiBold(),
                ],
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
                          widget.image!,
                          fit: BoxFit.contain,
                        ),
                      ),
                      if (widget.recognizedText != null)
                        Positioned.fill(
                          child: CustomPaint(
                            painter: BoundingBoxPainter(
                              lines: widget.recognizedText!.lines,
                              imageWidth: widget.recognizedText!.imageWidth,
                              imageHeight: widget.recognizedText!.imageHeight,
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
              child: Row(
                children: [
                  Expanded(
                    child: Builder(
                      builder: (innerContext) {
                        return SecondaryButton(
                          onPressed: viewModel.isLoading
                              ? null
                              : () => showKonteksDrawer(),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(LucideIcons.messageSquarePlus),
                              Gap(8),
                              Text('Beri Konteks'),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const Gap(16),
                  Expanded(
                    child: PrimaryButton(
                      onPressed:
                          viewModel.isLoading ? null : () => submitAnalisis(),
                      child: const Text('Analisis dengan AI'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (viewModel.isLoading)
          Positioned.fill(
            child: ScanAnimationOverlay(
              text: widget.recognizedText == null
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
    final images = widget.images!;
    final currentImg = images[_currentIndex];
    final currentRt = widget.recognizedTexts != null &&
            widget.recognizedTexts!.length > _currentIndex
        ? widget.recognizedTexts![_currentIndex]
        : null;

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
                      if (currentRt != null)
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
              child: Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      onPressed: () => showKonteksDrawer(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(LucideIcons.sparkles, size: 18),
                          const Gap(8),
                          Text(_customPrompt != null &&
                                  _customPrompt!.isNotEmpty
                              ? 'Konteks Aktif'
                              : 'Beri Konteks'),
                        ],
                      ),
                    ),
                  ),
                  const Gap(16),
                  Expanded(
                    child: PrimaryButton(
                      onPressed: viewModel.isLoading
                          ? null
                          : () => submitBatchAnalisis(),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.check, size: 18),
                          Gap(8),
                          Text('Proses Batch AI'),
                        ],
                      ),
                    ),
                  ),
                ],
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
