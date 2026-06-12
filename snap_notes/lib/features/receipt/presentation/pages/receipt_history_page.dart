import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:snap_notes/injection_container.dart';
import 'package:snap_notes/features/receipt/presentation/cubit/receipt_history_cubit.dart';
import 'package:snap_notes/features/receipt/presentation/cubit/receipt_history_state.dart';
import 'package:snap_notes/features/receipt/presentation/pages/receipt_detail_page.dart';
import 'package:snap_notes/features/pengeluaran/presentation/pages/pengeluaran_form_page.dart';
import 'package:snap_notes/features/pengeluaran/presentation/cubit/pengeluaran_form_cubit.dart';

class ReceiptHistoryPage extends StatelessWidget {
  const ReceiptHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final now = DateTime.now();
        return sl<ReceiptHistoryCubit>()..fetchReceipts(
          month: now.month.toString(),
          year: now.year.toString(),
        );
      },
      child: const ReceiptHistoryView(),
    );
  }
}

class ReceiptHistoryView extends StatelessWidget {
  const ReceiptHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      headers: [
        AppBar(
          title: const Text('Pengeluaran'),
          trailing: [
            IconButton.ghost(
              onPressed: () {
                final now = DateTime.now();
                context.read<ReceiptHistoryCubit>().fetchReceipts(
                  month: now.month.toString(),
                  year: now.year.toString(),
                );
              },
              icon: const Icon(LucideIcons.refreshCw),
            ),
            const Gap(16),
            IconButton.ghost(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider(
                      create: (_) => sl<PengeluaranFormCubit>(),
                      child: const PengeluaranFormPage(),
                    ),
                  ),
                );
              },
              icon: const Icon(LucideIcons.plus),
            ),
          ],
        ),
      ],
      child: BlocBuilder<ReceiptHistoryCubit, ReceiptHistoryState>(
        builder: (context, state) {
          if (state is ReceiptHistoryLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ReceiptHistoryError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Theme.of(context).colorScheme.destructive,
                    size: 48,
                  ),
                  const Gap(16),
                  Text(state.message).small(),
                  const Gap(16),
                  PrimaryButton(
                    onPressed: () {
                      final now = DateTime.now();
                      context.read<ReceiptHistoryCubit>().fetchReceipts(
                        month: now.month.toString(),
                        year: now.year.toString(),
                      );
                    },
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          } else if (state is ReceiptHistoryLoaded) {
            if (state.receipts.isEmpty) {
              return Center(
                child: const Text('Belum ada riwayat struk untuk bulan ini.').small().muted(),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.receipts.length,
              itemBuilder: (context, index) {
                final receipt = state.receipts[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Card(
                    padding: EdgeInsets.all(12),
                    child: GestureDetector(
                      onTap: () {
                        if (receipt.id != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ReceiptDetailPage(receiptId: receipt.id!),
                            ),
                          );
                        }
                      },
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.muted,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              LucideIcons.receipt,
                              size: 20,
                              color: Theme.of(context).colorScheme.mutedForeground,
                            ),
                          ),
                          const Gap(12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(receipt.storeName).xSmall(),
                                const Gap(2),
                                Text(receipt.date).xSmall().muted(),
                              ],
                            ),
                          ),
                          Text('Rp ${receipt.totalAmount.toStringAsFixed(0)}').small().medium(),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
