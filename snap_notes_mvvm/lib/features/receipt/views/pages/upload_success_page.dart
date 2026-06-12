import 'dart:io';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:snap_notes_mvvm/features/receipt/models/receipt.dart';
import 'package:snap_notes_mvvm/features/receipt/viewmodels/receipt_viewmodel.dart';

class UploadSuccessPage extends StatelessWidget {
  final File image;
  final Receipt receipt;

  const UploadSuccessPage({
    super.key,
    required this.image,
    required this.receipt,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ReceiptViewModel>();

    return Scaffold(
      headers: [
        AppBar(
          title: const Text('Upload Berhasil'),
        ),
      ],
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Gap(32),
                  // Success Icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary,
                      size: 64,
                    ),
                  ),
                  const Gap(24),
                  // Success Message
                  Text(
                    'Upload Berhasil!',
                    style: Theme.of(context).typography.large.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const Gap(8),
                  Text(
                    'Struk Anda berhasil diupload dan diproses',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).typography.small.copyWith(
                      color: Theme.of(context).colorScheme.mutedForeground,
                    ),
                  ),
                  const Gap(32),
                  // Receipt Summary Card
                  Card(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Ringkasan Struk').small().semiBold(),
                        const Gap(16),
                        // Image Preview
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            image,
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const Gap(16),
                        _buildInfoRow(context, 'Nama Toko', receipt.storeName),
                        _buildInfoRow(context, 'Tanggal', receipt.date),
                        _buildInfoRow(context, 'Total', 'Rp ${receipt.totalAmount.toStringAsFixed(0)}'),
                        const Gap(8),
                        const Text('Items:').small().semiBold(),
                        const Gap(8),
                        ...receipt.items.map((item) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(item.name).small(),
                                  ),
                                  Text('${item.quantity} x Rp ${item.price.toStringAsFixed(0)}').small().muted(),
                                  const Gap(8),
                                  Text('Rp ${item.totalPrice.toStringAsFixed(0)}').small().semiBold(),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Action Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: PrimaryButton(
              onPressed: () => viewModel.startCamera(),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.camera),
                  Gap(8),
                  Text('Scan Lagi'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
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
            child: Text(value).xSmall().medium(),
          ),
        ],
      ),
    );
  }
}
