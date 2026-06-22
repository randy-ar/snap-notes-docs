import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:snap_notes_mvvm/features/receipt/viewmodels/receipt_viewmodel.dart';

class PayloadPreviewPage extends StatefulWidget {
  final File image;
  final String rawText;
  final Map<String, dynamic> payload;
  final bool useScaffold;

  const PayloadPreviewPage({
    super.key,
    required this.image,
    required this.rawText,
    required this.payload,
    this.useScaffold = true,
  });

  @override
  State<PayloadPreviewPage> createState() => _PayloadPreviewPageState();
}

class _PayloadPreviewPageState extends State<PayloadPreviewPage> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ReceiptViewModel>();
    final jsonPayload = const JsonEncoder.withIndent('  ').convert(widget.payload);

    final mainContent = Column(
      children: [
        // Tab Selector
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: _buildTabButton(0, 'JSON', LucideIcons.code),
              ),
              const Gap(8),
              Expanded(
                child: _buildTabButton(1, 'Raw Text', LucideIcons.text),
              ),
              const Gap(8),
              Expanded(
                child: _buildTabButton(2, 'Image', LucideIcons.image),
              ),
            ],
          ),
        ),

        // Content
        Expanded(
          child: _buildTabContent(_selectedTab, jsonPayload),
        ),

        // Action Buttons
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
                      : () => viewModel.uploadToServer(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.upload, size: 18),
                      const Gap(6),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(viewModel.isLoading ? 'Mengupload...' : 'Upload ke Server'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
          title: const Text('Debug: Payload Preview'),
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

  Widget _buildTabButton(int index, String label, IconData icon) {
    final isSelected = _selectedTab == index;
    return isSelected
        ? PrimaryButton(
            onPressed: () => setState(() => _selectedTab = index),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16),
                const Gap(4),
                Text(label),
              ],
            ),
          )
        : SecondaryButton(
            onPressed: () => setState(() => _selectedTab = index),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16),
                const SizedBox(width: 4),
                Text(label),
              ],
            ),
          );
  }

  Widget _buildTabContent(int index, String jsonPayload) {
    switch (index) {
      case 0:
        return _buildJsonTab(jsonPayload);
      case 1:
        return _buildRawTextTab();
      case 2:
        return _buildImageTab();
      default:
        return _buildJsonTab(jsonPayload);
    }
  }

  Widget _buildJsonTab(String jsonPayload) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: const Text('Payload yang akan dikirim ke server:').medium(),
              ),
              OutlineButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: jsonPayload));
                  showToast(
                    context: context,
                    builder: (context, overlay) {
                      return const SurfaceCard(
                        child: Text('JSON copied to clipboard'),
                      );
                    },
                  );
                },
                child: const Icon(LucideIcons.copy),
              ),
            ],
          ),
          const Gap(8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SelectableText(
              jsonPayload,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                color: Color(0xFF4CAF50),
              ),
            ),
          ),
          const Gap(16),
          _buildPayloadInfo(),
        ],
      ),
    );
  }

  Widget _buildRawTextTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: const Text('Raw text dari ML Kit:').medium(),
              ),
              OutlineButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: widget.rawText));
                  showToast(
                    context: context,
                    builder: (context, overlay) {
                      return const SurfaceCard(
                        child: Text('Raw text copied to clipboard'),
                      );
                    },
                  );
                },
                child: const Icon(LucideIcons.copy),
              ),
            ],
          ),
          const Gap(8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.muted,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Theme.of(context).colorScheme.border),
            ),
            child: SelectableText(
              widget.rawText.isEmpty
                  ? '(Tidak ada teks)'
                  : widget.rawText,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Gambar yang akan diupload:').medium(),
          const Gap(8),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              widget.image,
              fit: BoxFit.contain,
            ),
          ),
          const Gap(16),
          _buildImageInfo(),
        ],
      ),
    );
  }

  Widget _buildPayloadInfo() {
    final linesCount = widget.payload['linesCount'] ?? 0;
    final imageSize = widget.payload['imageSize'] ?? {};

    return Card(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Payload Info:').small().semiBold(),
          const Gap(8),
          _buildInfoRow('Endpoint', 'POST /struk/scan'),
          _buildInfoRow('Content-Type', 'multipart/form-data'),
          _buildInfoRow('Lines Count', linesCount.toString()),
          _buildInfoRow('Image Width', '${imageSize['width']?.toInt() ?? 0}px'),
          _buildInfoRow('Image Height', '${imageSize['height']?.toInt() ?? 0}px'),
        ],
      ),
    );
  }

  Widget _buildImageInfo() {
    final file = File(widget.image.path);
    final size = file.existsSync() ? file.lengthSync() : 0;
    final sizeInKB = (size / 1024).toStringAsFixed(2);

    return Card(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('File Info:').small().semiBold(),
          const Gap(8),
          _buildInfoRow('Path', widget.image.path.split('/').last),
          _buildInfoRow('Full Path', widget.image.path),
          _buildInfoRow('Size', '$sizeInKB KB'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text('$label:').xSmall().medium().muted(),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).typography.xSmall.copyWith(
                fontWeight: FontWeight.w500,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
