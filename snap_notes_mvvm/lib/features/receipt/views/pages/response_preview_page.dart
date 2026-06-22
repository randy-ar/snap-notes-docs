import 'dart:io';
import 'package:flutter/material.dart' show Icons;
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:snap_notes_mvvm/features/receipt/models/receipt.dart';
import 'package:snap_notes_mvvm/features/receipt/viewmodels/receipt_viewmodel.dart';

class ResponsePreviewPage extends StatelessWidget {
  final File image;
  final Receipt receipt;

  const ResponsePreviewPage({
    super.key,
    required this.image,
    required this.receipt,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ReceiptViewModel>();
    final responseMap = receipt.toJson();

    return Scaffold(
      headers: [
        AppBar(
          title: const Text('Review Hasil Scan'),
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSuccessBanner(context),
                  const Gap(16),
                  
                  // Tampilkan gambar struk
                  const Text('Gambar Struk:').small().semiBold(),
                  const Gap(8),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.muted,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        image,
                        height: 300,
                        fit: BoxFit.contain,
                        alignment: Alignment.center,
                      ),
                    ),
                  ),
                  const Gap(24),

                  _buildParsedReceipt(context, responseMap),
                ],
              ),
            ),
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
                        Text('Simpan Data'),
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

  Widget _buildSuccessBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)),
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
                  'Ekstraksi Berhasil!',
                  style: Theme.of(context).typography.base.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const Text('AI berhasil menguraikan data struk belanja Anda.').xSmall().muted(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParsedReceipt(BuildContext context, Map<String, dynamic> responseMap) {
    return Card(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Data Struk:').small().semiBold(),
          const Gap(12),
          _buildDataRow('Nama Toko', receipt.storeName),
          _buildDataRow('Tanggal', receipt.date),
          _buildDataRow('Total', 'Rp ${receipt.totalAmount.toStringAsFixed(0)}'),
          const Gap(16),
          const Divider(),
          const Gap(16),
          const Text('Item Belanja:').small().semiBold(),
          const Gap(12),
          ...receipt.items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name).small().semiBold(),
                const Gap(4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${item.quantity} x Rp ${item.price.toStringAsFixed(0)}').xSmall().muted(),
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
            width: 100,
            child: Text(label).xSmall().muted(),
          ),
          Expanded(
            child: Text(value).small().semiBold(),
          ),
        ],
      ),
    );
  }
}
