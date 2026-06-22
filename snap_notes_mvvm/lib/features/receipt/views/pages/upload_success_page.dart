import 'dart:io';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:snap_notes_mvvm/features/receipt/models/receipt.dart';
import 'package:snap_notes_mvvm/features/receipt/viewmodels/receipt_viewmodel.dart';

class UploadSuccessPage extends StatelessWidget {
  final File image;
  final Receipt receipt;
  final bool useScaffold;

  const UploadSuccessPage({
    super.key,
    required this.image,
    required this.receipt,
    this.useScaffold = true,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ReceiptViewModel>();

    final mainContent = Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Success Banner (Similar to ResponsePreviewPage)
                _buildSuccessBanner(context),
                const Gap(24),

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
                  // Receipt Summary Card
                  Card(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Ringkasan Struk').small().semiBold(),
                        const Gap(16),

                        _buildInfoRow(context, 'Nama Toko', receipt.storeName),
                        _buildInfoRow(context, 'Kategori', receipt.categoryName ?? 'Lainnya'),
                        _buildInfoRow(context, 'Tanggal', receipt.date),
                        _buildInfoRow(context, 'Total', 'Rp ${receipt.totalAmount.toStringAsFixed(0)}'),
                        const Gap(16),
                        const Divider(),
                        const Gap(16),
                        const Text('Items:').small().semiBold(),
                        const Gap(8),
                        ...receipt.items.map((item) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(item.name).small(),
                                  ),
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
          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.check),
                        Gap(8),
                        Text('Selesai'),
                      ],
                    ),
                  ),
                ),
                const Gap(16),
                Expanded(
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
          ),
        ],
      );

    if (!useScaffold) {
      return mainContent;
    }

    return Scaffold(
      headers: [
        AppBar(
          title: const Text('Upload Berhasil'),
        ),
      ],
      child: mainContent,
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
                  'Data Tersimpan!',
                  style: Theme.of(context).typography.base.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const Text('Struk belanja Anda berhasil dikonfirmasi dan disimpan.').xSmall().muted(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
