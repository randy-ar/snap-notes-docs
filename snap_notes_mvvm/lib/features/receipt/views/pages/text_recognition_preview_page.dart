import 'dart:io';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:snap_notes_mvvm/features/receipt/models/recognized_text.dart';
import 'package:snap_notes_mvvm/features/receipt/viewmodels/receipt_viewmodel.dart';
import 'package:snap_notes_mvvm/features/receipt/views/widgets/scan_animation_overlay.dart';

class TextRecognitionPreviewPage extends StatefulWidget {
  final File image;
  final RecognizedText? recognizedText;
  final bool useScaffold;

  const TextRecognitionPreviewPage({
    super.key,
    required this.image,
    this.recognizedText,
    this.useScaffold = true,
  });

  @override
  State<TextRecognitionPreviewPage> createState() => _TextRecognitionPreviewPageState();
}

class _TextRecognitionPreviewPageState extends State<TextRecognitionPreviewPage> {
  String? _selectedCategory;
  String? _customPrompt;

  final List<String> categories = [
    'Makanan', 'Minuman', 'Sembako', 'Transportasi', 'Komunikasi',
    'Edukasi', 'Perawatan', 'Pakaian', 'Hiburan', 'Kesehatan',
    'Elektronik', 'Otomotif', 'Lainnya'
  ];

  void _showKonteksDrawer(BuildContext context) {
    final promptController = TextEditingController(text: _customPrompt);
    String? tempCategory = _selectedCategory;

    openDrawer(
      context: context,
      position: OverlayPosition.bottom,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Beri Konteks AI').large().semiBold(),
                  const Gap(8),
                  const Text('Pilih kategori dan/atau berikan instruksi tambahan sebelum AI menganalisis struk.').muted(),
                  const Gap(16),
                  
                  const Text('Kategori (Opsional)').medium(),
                  const Gap(4),
                  Select<String>(
                    itemBuilder: (context, item) => Text(item),
                    popup: SelectPopup.builder(
                      searchPlaceholder: const Text('Cari kategori'),
                      builder: (context, searchQuery) {
                        final filtered = searchQuery == null 
                            ? categories 
                            : categories.where((c) => c.toLowerCase().contains(searchQuery.toLowerCase())).toList();
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

                  const Text('Instruksi Tambahan (Opsional)').medium(),
                  const Gap(4),
                  TextField(
                    controller: promptController,
                    placeholder: const Text('Contoh: "Ini adalah struk tagihan internet bulanan"'),
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
                      closeOverlay(context);
                    },
                    child: const Text('Simpan Konteks'),
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ReceiptViewModel>();

    final mainContent = Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          widget.image,
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
                          onPressed: viewModel.isLoading ? null : () => _showKonteksDrawer(innerContext),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(LucideIcons.messageSquarePlus),
                              Gap(8),
                              Text('Beri Konteks'),
                            ],
                          ),
                        );
                      }
                    ),
                  ),
                  const Gap(16),
                  Expanded(
                    child: PrimaryButton(
                      onPressed: viewModel.isLoading
                          ? null
                          : () {
                              String combinedPrompt = '';
                              if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
                                combinedPrompt += 'Kategori yang disarankan: $_selectedCategory.\n';
                              }
                              if (_customPrompt != null && _customPrompt!.isNotEmpty) {
                                combinedPrompt += _customPrompt!;
                              }
                              viewModel.uploadToServer(combinedPrompt.isEmpty ? null : combinedPrompt.trim());
                            },
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

    if (!widget.useScaffold) {
      return mainContent;
    }

    return Scaffold(
      headers: [
        AppBar(
          title: const Text('Hasil Deteksi Teks'),
          leading: [
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
}

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


