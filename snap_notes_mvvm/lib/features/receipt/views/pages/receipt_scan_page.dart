import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snap_notes_mvvm/core/di/injection.dart';
import 'package:snap_notes_mvvm/features/receipt/viewmodels/receipt_viewmodel.dart';

class ReceiptScanPage extends StatelessWidget {
  const ReceiptScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return ChangeNotifierProvider(
      create: (context) => getIt<ReceiptViewModel>()
        ..loadReceipts(
          now.month.toString().padLeft(2, '0'),
          now.year.toString(),
        ),
      child: const ReceiptScanView(),
    );
  }
}

class ReceiptScanView extends StatelessWidget {
  const ReceiptScanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ReceiptViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(viewModel.errorMessage!),
                ElevatedButton(
                  onPressed: () {
                    final now = DateTime.now();
                    context.read<ReceiptViewModel>().loadReceipts(
                          now.month.toString().padLeft(2, '0'),
                          now.year.toString(),
                        );
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final list = viewModel.receiptList;
        if (list.isEmpty) {
          return const Center(
            child: Text('Belum ada struk. Scan struk untuk menambahkan.'),
          );
        }
        
        return ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, index) {
            final item = list[index];
            return ListTile(
              title: Text(item.storeName),
              subtitle: Text(item.date),
              trailing: Text('Rp ${item.totalAmount}'),
            );
          },
        );
      },
    );
  }
}

