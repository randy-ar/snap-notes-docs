import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter/material.dart' show MaterialPageRoute, RefreshIndicator;
import 'package:snap_notes/injection_container.dart';
import 'package:snap_notes/features/pemasukan/presentation/cubit/pemasukan_list_cubit.dart';
import 'package:snap_notes/features/pemasukan/presentation/pages/pemasukan_form_page.dart';
import 'package:snap_notes/features/pemasukan/presentation/cubit/pemasukan_form_cubit.dart';
import 'package:snap_notes/features/pemasukan/presentation/pages/pemasukan_detail_page.dart';
import 'package:snap_notes/features/notifikasi/presentation/pages/notifikasi_index_page.dart';
import 'package:snap_notes/features/notifikasi/presentation/cubit/notifikasi_list_cubit.dart';

class PemasukanListPage extends StatelessWidget {
  const PemasukanListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final now = DateTime.now();
        return sl<PemasukanListCubit>()..fetchPemasukan(
          bulan: now.month,
          tahun: now.year,
        );
      },
      child: const PemasukanListView(),
    );
  }
}

class PemasukanListView extends StatelessWidget {
  const PemasukanListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      headers: [
        AppBar(
          title: const Text('Pemasukan'),
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
                context.read<PemasukanListCubit>().fetchPemasukan(
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
                      create: (_) => sl<PemasukanFormCubit>(),
                      child: const PemasukanFormPage(),
                    ),
                  ),
                ).then((_) {
                  final now = DateTime.now();
                  context.read<PemasukanListCubit>().fetchPemasukan(
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
      child: BlocBuilder<PemasukanListCubit, PemasukanListState>(
        builder: (context, state) {
          if (state is PemasukanListLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PemasukanListError) {
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
                      context.read<PemasukanListCubit>().fetchPemasukan(
                        bulan: now.month,
                        tahun: now.year,
                      );
                    },
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          } else if (state is PemasukanListLoaded) {
            if (state.pemasukanList.isEmpty) {
              return Center(
                child: const Text('Belum ada riwayat pemasukan untuk bulan ini.').small().muted(),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                final now = DateTime.now();
                context.read<PemasukanListCubit>().fetchPemasukan(
                  bulan: now.month,
                  tahun: now.year,
                );
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.pemasukanList.length,
                itemBuilder: (context, index) {
                  final pemasukan = state.pemasukanList[index];
                  
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
                                  PemasukanDetailPage(pemasukanId: pemasukan.id),
                            ),
                          ).then((_) {
                            final now = DateTime.now();
                            context.read<PemasukanListCubit>().fetchPemasukan(
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

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
