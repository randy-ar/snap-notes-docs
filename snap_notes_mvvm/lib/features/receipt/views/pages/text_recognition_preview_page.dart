import 'dart:io';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:snap_notes_mvvm/features/receipt/models/recognized_text.dart';
import 'package:snap_notes_mvvm/features/receipt/viewmodels/receipt_viewmodel.dart';

class TextRecognitionPreviewPage extends StatelessWidget {
  final File image;
  final RecognizedText recognizedText;

  const TextRecognitionPreviewPage({
    super.key,
    required this.image,
    required this.recognizedText,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ReceiptViewModel>();

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
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gambar dengan bounding box
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          image,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Positioned.fill(
                        child: CustomPaint(
                          painter: BoundingBoxPainter(
                            lines: recognizedText.lines,
                            imageWidth: recognizedText.imageWidth,
                            imageHeight: recognizedText.imageHeight,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(16),

                  // Statistik deteksi
                  Card(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStat(context, 'Baris Terdeteksi', recognizedText.lines.length.toString()),
                        _buildStat(context, 'Karakter', recognizedText.text.length.toString()),
                        _buildStat(context, 'Ukuran', '${recognizedText.imageWidth.toInt()}x${recognizedText.imageHeight.toInt()}'),
                      ],
                    ),
                  ),
                  const Gap(16),

                  // Teks Terdeteksi
                  const Text('Teks Terdeteksi:').small().semiBold(),
                  const Gap(8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.muted,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Theme.of(context).colorScheme.border),
                    ),
                    child: Text(
                      recognizedText.text.isEmpty
                          ? '(Tidak ada teks terdeteksi)'
                          : recognizedText.text,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Gap(16),

                  // Detail baris
                  Text('Detail Baris (${recognizedText.lines.length}):').small().semiBold(),
                  const Gap(8),
                  ...recognizedText.lines.map((line) {
                    return Card(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Baris #${line.lineIndex + 1}').small().bold(),
                          const Gap(4),
                          Text(line.text).small(),
                          const Gap(4),
                          Text('Box: (${line.boundingBox.left.toInt()}, ${line.boundingBox.top.toInt()}) - (${line.boundingBox.right.toInt()}, ${line.boundingBox.bottom.toInt()})').xSmall().muted(),
                        ],
                      ),
                    );
                  }),
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
                    onPressed: () => viewModel.cancelScan(),
                    child: const Text('Batal'),
                  ),
                ),
                const Gap(16),
                Expanded(
                  child: PrimaryButton(
                    onPressed: viewModel.isLoading
                        ? null
                        : () => viewModel.proceedToPayload(),
                    child: const Text('Lanjut ke Payload'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(value).large().bold(),
        Text(label).xSmall().muted(),
      ],
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
