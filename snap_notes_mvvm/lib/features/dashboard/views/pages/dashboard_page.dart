import 'package:flutter/material.dart' show RefreshIndicator, MaterialPageRoute;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:provider/provider.dart';
import 'package:snap_notes_mvvm/core/di/injection.dart';
import 'package:snap_notes_mvvm/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:snap_notes_mvvm/features/dashboard/viewmodels/dashboard_viewmodel.dart';
import 'package:snap_notes_mvvm/features/notifikasi/viewmodels/notifikasi_viewmodel.dart';
import 'package:snap_notes_mvvm/features/pengeluaran/viewmodels/pengeluaran_viewmodel.dart';
import 'package:snap_notes_mvvm/features/dashboard/views/widgets/expense_heatmap_widget.dart';
import 'package:snap_notes_mvvm/features/dashboard/views/widgets/expense_line_chart_widget.dart';
import 'package:snap_notes_mvvm/features/dashboard/views/widgets/expense_pie_chart_widget.dart';
import 'package:snap_notes_mvvm/features/notifikasi/views/pages/notifikasi_settings_page.dart';
import 'package:intl/intl.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) {
            final now = DateTime.now();
            return getIt<DashboardViewModel>()
              ..loadRingkasan(bulan: now.month, tahun: now.year)
              ..loadMonthlyTrend();
          },
        ),
        ChangeNotifierProvider(
          create: (context) {
            return getIt<PengeluaranViewModel>()..loadPengeluaran();
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
    final dashboardViewModel = context.watch<DashboardViewModel>();
    final pengeluaranViewModel = context.watch<PengeluaranViewModel>();
    
    return Scaffold(
      headers: [
        AppBar(
          title: const Text('Dashboard'),
          trailing: [
            IconButton.ghost(
              icon: const Icon(LucideIcons.bell),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider(
                      create: (_) => getIt<NotifikasiViewModel>(),
                      child: const NotifikasiSettingsPage(),
                    ),
                  ),
                );
              },
            ),
            IconButton.ghost(
              icon: Icon(LucideIcons.logOut, color: Theme.of(context).colorScheme.destructive),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('Keluar Aplikasi'),
                    content: const Text('Apakah Anda yakin ingin keluar dari akun Anda?'),
                    actions: [
                      OutlineButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('Batal'),
                      ),
                      DestructiveButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          context.read<AuthViewModel>().logout();
                        },
                        child: const Text('Keluar'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ],
      child: Builder(
        builder: (context) {
          if (dashboardViewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (dashboardViewModel.errorMessage != null) {
            return Center(child: Text(dashboardViewModel.errorMessage!).muted());
          } else if (dashboardViewModel.ringkasan != null) {
            final ringkasan = dashboardViewModel.ringkasan!;
            
            return RefreshIndicator(
              onRefresh: () async {
                final now = DateTime.now();
                context.read<DashboardViewModel>().loadRingkasan(bulan: now.month, tahun: now.year);
                context.read<DashboardViewModel>().loadMonthlyTrend();
                context.read<PengeluaranViewModel>().loadPengeluaran();
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
                                    Icon(LucideIcons.arrowDown, color: Theme.of(context).colorScheme.mutedForeground, size: 14),
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
                                    Icon(LucideIcons.arrowUp, color: Theme.of(context).colorScheme.mutedForeground, size: 14),
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
                  // 1. Kalendar Heatmap
                  if (pengeluaranViewModel.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (pengeluaranViewModel.pengeluaranList.isNotEmpty)
                    ExpenseHeatmapWidget(dataTransaksi: pengeluaranViewModel.pengeluaranList)
                  else
                    const SizedBox.shrink(),
                  const Gap(24),
                  // 2. Line Chart
                  const ExpenseLineChartWidget(),
                  const Gap(24),
                  // 3. Pie Chart
                  if (!pengeluaranViewModel.isLoading)
                    ExpensePieChartWidget(dataTransaksi: pengeluaranViewModel.pengeluaranList),
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

