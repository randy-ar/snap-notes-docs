import 'package:flutter/material.dart' show RefreshIndicator;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:snap_notes/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:snap_notes/features/notifikasi/presentation/cubit/notifikasi_list_cubit.dart';
import 'package:snap_notes/features/dashboard/presentation/widgets/expense_heatmap_widget.dart';
import 'package:snap_notes/features/pengeluaran/presentation/cubit/pengeluaran_list_cubit.dart';
import 'package:snap_notes/features/notifikasi/presentation/pages/notifikasi_index_page.dart';
import 'package:snap_notes/injection_container.dart';
import 'package:intl/intl.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) {
            final now = DateTime.now();
            return sl<DashboardCubit>()..fetchRingkasan(bulan: now.month, tahun: now.year);
          },
        ),
        BlocProvider(
          create: (context) {
            // Ambil semua riwayat pengeluaran untuk heatmap (tanpa filter bulan)
            return sl<PengeluaranListCubit>()..fetchPengeluaran();
          },
        ),
      ],
      child: const DashboardView(),
    );
  }
}

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    
    return Scaffold(
      headers: [
        AppBar(
          title: const Text('Dashboard'),
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
          ],
        ),
      ],
      child: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DashboardError) {
            return Center(child: Text(state.message).muted());
          } else if (state is DashboardLoaded) {
            final ringkasan = state.ringkasan;
            
            return RefreshIndicator(
              onRefresh: () async {
                final now = DateTime.now();
                context.read<DashboardCubit>().fetchRingkasan(bulan: now.month, tahun: now.year);
                context.read<PengeluaranListCubit>().fetchPengeluaran();
              },
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  const Text('Ringkasan Bulan Ini').h3(),
                  const Gap(16),
                  
                  // Compact Monochrome Card for Total Balance
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.card,
                      border: Border.all(color: Theme.of(context).colorScheme.border),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Saldo Tersedia').muted(),
                        const Gap(4),
                        Text(currencyFormat.format(ringkasan.saldo)).h2(),
                        const Gap(16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.arrow_downward, color: Theme.of(context).colorScheme.mutedForeground, size: 14),
                                    const Gap(4),
                                    const Text('Pemasukan').muted(),
                                  ],
                                ),
                                const Gap(2),
                                Text(currencyFormat.format(ringkasan.totalPemasukan)).large(),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    const Text('Pengeluaran').muted(),
                                    const Gap(4),
                                    Icon(Icons.arrow_upward, color: Theme.of(context).colorScheme.mutedForeground, size: 14),
                                  ],
                                ),
                                const Gap(2),
                                Text(currencyFormat.format(ringkasan.totalPengeluaran)).large(),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Gap(24),
                  BlocBuilder<PengeluaranListCubit, PengeluaranListState>(
                    builder: (context, pengeluaranState) {
                      if (pengeluaranState is PengeluaranListLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (pengeluaranState is PengeluaranListLoaded) {
                        return ExpenseHeatmapWidget(dataTransaksi: pengeluaranState.pengeluaranList);
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            );
          }
          
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
