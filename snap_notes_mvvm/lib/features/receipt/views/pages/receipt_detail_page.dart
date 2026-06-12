import 'package:flutter/material.dart' show RefreshIndicator;
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:snap_notes_mvvm/core/di/injection.dart';
import 'package:snap_notes_mvvm/features/receipt/models/receipt.dart';
import 'package:snap_notes_mvvm/features/receipt/viewmodels/receipt_viewmodel.dart';

class ReceiptDetailPage extends StatelessWidget {
  final String receiptId;

  const ReceiptDetailPage({super.key, required this.receiptId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<ReceiptViewModel>()..getReceiptDetail(receiptId),
      child: ReceiptDetailView(receiptId: receiptId),
    );
  }
}

class ReceiptDetailView extends StatelessWidget {
  final String receiptId;

  const ReceiptDetailView({super.key, required this.receiptId});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ReceiptViewModel>();

    return Scaffold(
      headers: [
        AppBar(
          title: const Text('Detail Struk'),
          leading: [
            IconButton.ghost(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(LucideIcons.arrowLeft),
            ),
          ],
        ),
      ],
      child: Builder(
        builder: (context) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Theme.of(context).colorScheme.destructive, size: 48),
                  const Gap(16),
                  Text(viewModel.errorMessage!).small(),
                  const Gap(16),
                  PrimaryButton(
                    onPressed: () => context.read<ReceiptViewModel>().getReceiptDetail(receiptId),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          final receipt = viewModel.receiptDetail;
          if (receipt == null) {
            return const Center(child: Text('Struk tidak ditemukan'));
          }

          return RefreshIndicator(
            onRefresh: () => context.read<ReceiptViewModel>().getReceiptDetail(receiptId),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (receipt.imageUrl != null && receipt.imageUrl!.isNotEmpty) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        receipt.imageUrl!,
                        height: 300,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 200,
                          color: Theme.of(context).colorScheme.muted,
                          child: Center(
                            child: Icon(LucideIcons.imageOff, color: Theme.of(context).colorScheme.mutedForeground, size: 48),
                          ),
                        ),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 300,
                            color: Theme.of(context).colorScheme.muted,
                            child: const Center(child: CircularProgressIndicator()),
                          );
                        },
                      ),
                    ),
                    const Gap(24),
                  ],
                  
                  Card(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(receipt.storeName).large().bold(),
                            ),
                            if (receipt.categoryName != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.muted,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(receipt.categoryName!).xSmall(),
                              ),
                          ],
                        ),
                        const Gap(8),
                        Row(
                          children: [
                            Icon(LucideIcons.calendar, size: 16, color: Theme.of(context).colorScheme.mutedForeground),
                            const Gap(8),
                            Text(receipt.date).small().muted(),
                          ],
                        ),
                        const Gap(24),
                        const Divider(),
                        const Gap(16),
                        const Text('Item Belanja').small().semiBold(),
                        const Gap(12),
                        ...receipt.items.map((item) => _buildItemRow(context, item)),
                        const Gap(16),
                        const Divider(),
                        const Gap(16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total').small().semiBold(),
                            Text('Rp ${receipt.totalAmount.toStringAsFixed(0)}').small().semiBold(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildItemRow(BuildContext context, ReceiptItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name).small().medium(),
                if (item.categoryName != null)
                  Text(item.categoryName!).xSmall().muted(),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '${item.quantity} x ${item.price.toStringAsFixed(0)}',
              textAlign: TextAlign.center,
              style: Theme.of(context).typography.small.copyWith(
                color: Theme.of(context).colorScheme.mutedForeground,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Rp ${item.totalPrice.toStringAsFixed(0)}',
              textAlign: TextAlign.right,
              style: Theme.of(context).typography.small.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
