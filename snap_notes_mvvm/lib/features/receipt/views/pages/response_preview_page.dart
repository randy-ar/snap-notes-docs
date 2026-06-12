import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:snap_notes_mvvm/features/receipt/models/receipt.dart';
import 'package:snap_notes_mvvm/features/receipt/viewmodels/receipt_viewmodel.dart';

class ResponsePreviewPage extends StatefulWidget {
  final File image;
  final Receipt receipt;

  const ResponsePreviewPage({
    super.key,
    required this.image,
    required this.receipt,
  });

  @override
  State<ResponsePreviewPage> createState() => _ResponsePreviewPageState();
}

class _ResponsePreviewPageState extends State<ResponsePreviewPage> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ReceiptViewModel>();
    final responseMap = widget.receipt.toJson();
    final jsonResponse = const JsonEncoder.withIndent('  ').convert(responseMap);

    return Scaffold(
      headers: [
        AppBar(
          title: const Text('Debug: Response Preview'),
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
          // Tab Selector
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: _buildTabButton(0, 'Parsed', LucideIcons.receipt),
                ),
                const Gap(8),
                Expanded(
                  child: _buildTabButton(1, 'JSON', LucideIcons.code),
                ),
                const Gap(8),
                Expanded(
                  child: _buildTabButton(2, 'Tree', LucideIcons.folderTree),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _buildTabContent(_selectedTab, jsonResponse, responseMap),
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
                    onPressed: () => viewModel.confirmReceipt(),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.check),
                        Gap(8),
                        Text('Konfirmasi Data'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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

  Widget _buildTabContent(int index, String jsonResponse, Map<String, dynamic> responseMap) {
    switch (index) {
      case 0:
        return _buildParsedDataTab(responseMap);
      case 1:
        return _buildJsonTab(jsonResponse);
      case 2:
        return _buildTreeTab(responseMap);
      default:
        return _buildParsedDataTab(responseMap);
    }
  }

  Widget _buildParsedDataTab(Map<String, dynamic> responseMap) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSuccessBanner(),
          const Gap(16),
          _buildParsedReceipt(responseMap),
        ],
      ),
    );
  }

  Widget _buildJsonTab(String jsonResponse) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: const Text('Response dari server:').medium(),
              ),
              OutlineButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: jsonResponse));
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
              jsonResponse,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                color: Color(0xFF4CAF50),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTreeTab(Map<String, dynamic> responseMap) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: _buildJsonTree(responseMap),
    );
  }

  Widget _buildSuccessBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary, size: 32),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upload Berhasil!',
                  style: Theme.of(context).typography.base.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const Text('Server berhasil memproses struk').xSmall().muted(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParsedReceipt(Map<String, dynamic> responseMap) {
    return Card(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Data Struk yang Diparsing:').small().semiBold(),
          const Gap(16),
          _buildDataRow('ID', responseMap['id']?.toString() ?? '-'),
          _buildDataRow('Nama Toko', widget.receipt.storeName),
          _buildDataRow('Tanggal', widget.receipt.date),
          _buildDataRow('Total', 'Rp ${widget.receipt.totalAmount.toStringAsFixed(0)}'),
          if (responseMap['gambarUrl'] != null)
            _buildDataRow('Image URL', responseMap['gambarUrl'].toString()),
          const Gap(16),
          const Text('Items:').small().semiBold(),
          const Gap(8),
          ...widget.receipt.items.map((item) => Card(
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
              )),
        ],
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text('$label:').xSmall().medium().muted(),
          ),
          Expanded(
            child: Text(value).xSmall().medium(),
          ),
        ],
      ),
    );
  }

  Widget _buildJsonTree(dynamic data, {int indent = 0}) {
    if (data is Map) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: data.entries.map((entry) {
          return Padding(
            padding: EdgeInsets.only(left: indent * 16.0, top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '"${entry.key}": ',
                      style: const TextStyle(
                        color: Color(0xFF2196F3),
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                    if (entry.value is! Map && entry.value is! List)
                      _buildJsonValue(entry.value),
                  ],
                ),
                if (entry.value is Map || entry.value is List)
                  _buildJsonTree(entry.value, indent: indent + 1),
              ],
            ),
          );
        }).toList(),
      );
    } else if (data is List) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: data.asMap().entries.map((entry) {
          return Padding(
            padding: EdgeInsets.only(left: indent * 16.0, top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '[${entry.key}]:',
                  style: const TextStyle(
                    color: Color(0xFFFF9800),
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
                _buildJsonTree(entry.value, indent: indent + 1),
              ],
            ),
          );
        }).toList(),
      );
    }
    return _buildJsonValue(data);
  }

  Widget _buildJsonValue(dynamic value) {
    Color color;
    if (value == null) {
      color = const Color(0xFF9E9E9E);
    } else if (value is bool) {
      color = const Color(0xFF9C27B0);
    } else if (value is num) {
      color = const Color(0xFFFF9800);
    } else {
      color = const Color(0xFF4CAF50);
    }

    return Text(
      value?.toString() ?? 'null',
      style: TextStyle(
        color: color,
        fontFamily: 'monospace',
        fontSize: 12,
      ),
    );
  }
}
