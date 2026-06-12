import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:snap_notes/features/receipt/domain/entities/recognized_text_entity.dart';
import 'package:snap_notes/features/receipt/presentation/bloc/receipt_bloc.dart';
import 'package:snap_notes/features/receipt/presentation/bloc/receipt_event.dart';

class TextRecognitionPreviewPage extends StatelessWidget {
  final File image;
  final RecognizedTextEntity recognizedText;

  const TextRecognitionPreviewPage({
    super.key,
    required this.image,
    required this.recognizedText,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      headers: [
        AppBar(
          title: const Text('Hasil Deteksi Teks'),
          leading: [
            IconButton.ghost(
              onPressed: () => context.read<ReceiptBloc>().add(
                CancelReceiptEvent(),
              ),
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
                  // Image with bounding boxes
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

                  // Stats
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

                  // Detected text preview
                  const Text('Teks Terdeteksi:').small().semiBold(),
                  const Gap(8),
                  Container(
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

                  // Lines detail
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
                    onPressed: () => context.read<ReceiptBloc>().add(
                      CancelReceiptEvent(),
                    ),
                    child: const Text('Batal'),
                  ),
                ),
                const Gap(16),
                Expanded(
                  child: PrimaryButton(
                    onPressed: () => context.read<ReceiptBloc>().add(
                      ProceedToPayloadEvent(
                        image: image,
                        recognizedText: recognizedText,
                      ),
                    ),
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

      // Draw filled rectangle
      canvas.drawRect(rect, fillPaint);

      // Draw border
      canvas.drawRect(rect, paint);

      // Draw line number
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
