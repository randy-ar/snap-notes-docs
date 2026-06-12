import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter/material.dart' show MaterialPageRoute, RefreshIndicator;
import 'package:snap_notes/injection_container.dart';
import 'package:snap_notes/features/pengeluaran/presentation/cubit/pengeluaran_list_cubit.dart';
import 'package:snap_notes/features/pengeluaran/presentation/pages/pengeluaran_form_page.dart';
import 'package:snap_notes/features/pengeluaran/presentation/cubit/pengeluaran_form_cubit.dart';
import 'package:snap_notes/features/pengeluaran/presentation/pages/pengeluaran_detail_page.dart';
import 'package:snap_notes/features/notifikasi/presentation/pages/notifikasi_index_page.dart';
import 'package:snap_notes/features/notifikasi/presentation/cubit/notifikasi_list_cubit.dart';

class PengeluaranListPage extends StatelessWidget {
  const PengeluaranListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final now = DateTime.now();
        return sl<PengeluaranListCubit>()..fetchPengeluaran(
          bulan: now.month,
          tahun: now.year,
        );
      },
      child: const PengeluaranListView(),
    );
  }
}

class PengeluaranListView extends StatelessWidget {
  const PengeluaranListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      headers: [
        AppBar(
          title: const Text('Pengeluaran'),
          trailing: [
            IconButton.ghost(
              icon: const Icon(Icons.notifications),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) => sl<NotifikasiListCubit>(),
                      child: const NotifikasiIndexPage(),
                    ),
                  ),
                );
              },
            ),
            const Gap(8),
            IconButton.ghost(
              onPressed: () {
                final now = DateTime.now();
                context.read<PengeluaranListCubit>().fetchPengeluaran(
                  bulan: now.month,
                  tahun: now.year,
                );
              },
              icon: const Icon(Icons.refresh),
            ),
            const Gap(8),
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
                ).then((_) {
                  final now = DateTime.now();
                  context.read<PengeluaranListCubit>().fetchPengeluaran(
                    bulan: now.month,
                    tahun: now.year,
                  );
                });
              },
              icon: const Icon(LucideIcons.plus),
            ),
          ],
        ),
      ],
      child: BlocBuilder<PengeluaranListCubit, PengeluaranListState>(
        builder: (context, state) {
          if (state is PengeluaranListLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PengeluaranListError) {
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
                      context.read<PengeluaranListCubit>().fetchPengeluaran(
                        bulan: now.month,
                        tahun: now.year,
                      );
                    },
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          } else if (state is PengeluaranListLoaded) {
            if (state.pengeluaranList.isEmpty) {
              return Center(
                child: const Text('Belum ada riwayat pengeluaran untuk bulan ini.').small().muted(),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                final now = DateTime.now();
                context.read<PengeluaranListCubit>().fetchPengeluaran(
                  bulan: now.month,
                  tahun: now.year,
                );
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.pengeluaranList.length,
                itemBuilder: (context, index) {
                  final pengeluaran = state.pengeluaranList[index];
                  final bool fromOcr = pengeluaran.strukId != null;
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Card(
                      padding: const EdgeInsets.all(12),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PengeluaranDetailPage(pengeluaranId: pengeluaran.id),
                            ),
                          ).then((_) {
                            final now = DateTime.now();
                            context.read<PengeluaranListCubit>().fetchPengeluaran(
                              bulan: now.month,
                              tahun: now.year,
                            );
                          });
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

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
