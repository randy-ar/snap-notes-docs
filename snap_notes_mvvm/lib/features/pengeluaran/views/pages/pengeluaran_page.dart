import 'package:flutter/material.dart' show RefreshIndicator, MaterialPageRoute;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:provider/provider.dart';
import 'package:snap_notes_mvvm/core/di/injection.dart';
import 'package:snap_notes_mvvm/features/pengeluaran/viewmodels/pengeluaran_viewmodel.dart';
import 'package:snap_notes_mvvm/features/pengeluaran/views/pages/pengeluaran_detail_page.dart';
import 'package:snap_notes_mvvm/features/pengeluaran/views/pages/pengeluaran_form_page.dart';
import 'package:snap_notes_mvvm/features/receipt/views/pages/receipt_detail_page.dart';

class PengeluaranPage extends StatelessWidget {
  const PengeluaranPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final now = DateTime.now();
        return getIt<PengeluaranViewModel>()..loadPengeluaran(bulan: now.month, tahun: now.year);
      },
      child: const PengeluaranView(),
    );
  }
}

class PengeluaranView extends StatelessWidget {
  const PengeluaranView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PengeluaranViewModel>();
    
    return Scaffold(
      headers: [
        AppBar(
          title: const Text('Pengeluaran'),
          trailing: [
            IconButton.ghost(
              onPressed: () {
                final now = DateTime.now();
                context.read<PengeluaranViewModel>().loadPengeluaran(bulan: now.month, tahun: now.year);
              },
              icon: const Icon(Icons.refresh),
            ),
            const Gap(8),
            IconButton.ghost(
              onPressed: () async {
                final vm = context.read<PengeluaranViewModel>();
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider.value(
                      value: vm,
                      child: const PengeluaranFormPage(),
                    ),
                  ),
                );
                if (result == true && context.mounted) {
                  final now = DateTime.now();
                  context.read<PengeluaranViewModel>().loadPengeluaran(bulan: now.month, tahun: now.year);
                }
              },
              icon: const Icon(LucideIcons.plus),
            ),
          ],
        ),
      ],
      child: Builder(
        builder: (context) {
          if (viewModel.isLoading && viewModel.pengeluaranList.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          } else if (viewModel.errorMessage != null && viewModel.pengeluaranList.isEmpty) {
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
                  Text(viewModel.errorMessage!).small(),
                  const Gap(16),
                  PrimaryButton(
                    onPressed: () {
                      final now = DateTime.now();
                      context.read<PengeluaranViewModel>().loadPengeluaran(bulan: now.month, tahun: now.year);
                    },
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          } else {
            if (viewModel.pengeluaranList.isEmpty) {
              return Center(
                child: const Text('Belum ada riwayat pengeluaran untuk bulan ini.').small().muted(),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                final now = DateTime.now();
                context.read<PengeluaranViewModel>().loadPengeluaran(bulan: now.month, tahun: now.year);
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: viewModel.pengeluaranList.length,
                itemBuilder: (context, index) {
                  final pengeluaran = viewModel.pengeluaranList[index];
                  final bool fromOcr = pengeluaran.strukId != null;
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Card(
                      padding: const EdgeInsets.all(12),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () async {
                          final vm = context.read<PengeluaranViewModel>();
                          bool? result;
                          
                          if (fromOcr) {
                            result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReceiptDetailPage(receiptId: pengeluaran.strukId!),
                              ),
                            );
                          } else {
                            result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PengeluaranDetailPage(pengeluaranId: pengeluaran.id),
                              ),
                            );
                          }
                          
                          if (result == true && context.mounted) {
                            final now = DateTime.now();
                            vm.loadPengeluaran(bulan: now.month, tahun: now.year);
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
                                fromOcr ? Icons.receipt_long : LucideIcons.wallet,
                                size: 20,
                                color: fromOcr 
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.mutedForeground,
                              ),
                            ),
                            const Gap(12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    pengeluaran.deskripsi,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ).small().semiBold(),
                                  const Gap(2),
                                  Text('${pengeluaran.tanggal.day}/${pengeluaran.tanggal.month}/${pengeluaran.tanggal.year}').small().muted(),
                                ],
                              ),
                            ),
                            Text('Rp ${pengeluaran.jumlah.toStringAsFixed(0)}').small().semiBold(),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}
