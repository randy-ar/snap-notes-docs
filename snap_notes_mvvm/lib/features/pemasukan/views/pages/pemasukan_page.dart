import 'package:flutter/material.dart' show RefreshIndicator, MaterialPageRoute;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:provider/provider.dart';
import 'package:snap_notes_mvvm/core/di/injection.dart';
import 'package:snap_notes_mvvm/features/pemasukan/viewmodels/pemasukan_viewmodel.dart';
import 'package:snap_notes_mvvm/features/pemasukan/views/pages/pemasukan_detail_page.dart';
import 'package:snap_notes_mvvm/features/pemasukan/views/pages/pemasukan_form_page.dart';

class PemasukanPage extends StatelessWidget {
  const PemasukanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final now = DateTime.now();
        return getIt<PemasukanViewModel>()..loadPemasukan(bulan: now.month, tahun: now.year);
      },
      child: const PemasukanView(),
    );
  }
}

class PemasukanView extends StatelessWidget {
  const PemasukanView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PemasukanViewModel>();
    
    return Scaffold(
      headers: [
        AppBar(
          title: const Text('Pemasukan'),
          trailing: [
            IconButton.ghost(
              onPressed: () {
                final now = DateTime.now();
                context.read<PemasukanViewModel>().loadPemasukan(bulan: now.month, tahun: now.year);
              },
              icon: const Icon(Icons.refresh),
            ),
            const Gap(8),
            IconButton.ghost(
              onPressed: () async {
                final vm = context.read<PemasukanViewModel>();
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider.value(
                      value: vm,
                      child: const PemasukanFormPage(),
                    ),
                  ),
                );
                if (result == true && context.mounted) {
                  final now = DateTime.now();
                  context.read<PemasukanViewModel>().loadPemasukan(bulan: now.month, tahun: now.year);
                }
              },
              icon: const Icon(LucideIcons.plus),
            ),
          ],
        ),
      ],
      child: Builder(
        builder: (context) {
          if (viewModel.isLoading && viewModel.pemasukanList.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          } else if (viewModel.errorMessage != null && viewModel.pemasukanList.isEmpty) {
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
                      context.read<PemasukanViewModel>().loadPemasukan(bulan: now.month, tahun: now.year);
                    },
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          } else {
            if (viewModel.pemasukanList.isEmpty) {
              return Center(
                child: const Text('Belum ada riwayat pemasukan untuk bulan ini.').small().muted(),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                final now = DateTime.now();
                context.read<PemasukanViewModel>().loadPemasukan(bulan: now.month, tahun: now.year);
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: viewModel.pemasukanList.length,
                itemBuilder: (context, index) {
                  final pemasukan = viewModel.pemasukanList[index];
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Card(
                      padding: const EdgeInsets.all(12),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () async {
                          final result = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PemasukanDetailPage(pemasukanId: pemasukan.id),
                            ),
                          );
                          if (result == true && context.mounted) {
                            final now = DateTime.now();
                            context.read<PemasukanViewModel>().loadPemasukan(bulan: now.month, tahun: now.year);
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
                                LucideIcons.wallet,
                                size: 20,
                                color: Theme.of(context).colorScheme.mutedForeground,
                              ),
                            ),
                            const Gap(12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    pemasukan.deskripsi,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ).small().semiBold(),
                                  const Gap(2),
                                  Text('${pemasukan.tanggal.day}/${pemasukan.tanggal.month}/${pemasukan.tanggal.year}').small().muted(),
                                ],
                              ),
                            ),
                            Text('Rp ${pemasukan.jumlah.toStringAsFixed(0)}').small().semiBold(),
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

