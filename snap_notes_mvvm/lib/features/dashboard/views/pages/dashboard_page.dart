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
import 'package:snap_notes_mvvm/core/utils/toast_formatter.dart';

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
              ..initDashboard(bulan: now.month, tahun: now.year);
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
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final dashboardViewModel = context.watch<DashboardViewModel>();
    final pengeluaranViewModel = context.watch<PengeluaranViewModel>();

    return Scaffold(
      headers: [
        AppBar(
          leading: [
            Consumer<AuthViewModel>(
              builder: (context, authState, child) {
                final pengguna = authState.pengguna;
                final namaLengkap = pengguna?.namaLengkap;
                final name = (namaLengkap != null && namaLengkap.isNotEmpty)
                    ? namaLengkap
                    : 'User';
                final photoUrl = pengguna?.fotoProfilUrl;

                return Builder(
                  builder: (context) {
                    return IconButton.ghost(
                      icon: Avatar(
                        initials: Avatar.getInitials(name),
                        size: 32,
                        provider: photoUrl != null
                            ? NetworkImage(photoUrl)
                            : null,
                      ),
                      onPressed: () {
                        final authViewModel = context.read<AuthViewModel>();
                        showPopover(
                          context: context,
                          alignment: Alignment.bottomLeft,
                          offset: const Offset(-48, 8),
                          handler: OverlayHandler.popover,
                          builder: (popoverContext) {
                            return ModalContainer(
                              child: SizedBox(
                                width: 220,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(name).small().bold(),
                                          if (pengguna?.email != null) ...[
                                            const Gap(2),
                                            Text(pengguna!.email).xSmall().muted(),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const Divider(height: 1),
                                    GhostButton(
                                      onPressed: () {
                                        closeOverlay(popoverContext);
                                        showDialog(
                                          context: context,
                                          builder: (dialogContext) => AlertDialog(
                                            title: const Text(
                                              'Keluar Aplikasi',
                                            ),
                                            content: const Text(
                                              'Apakah Anda yakin ingin keluar dari akun Anda?',
                                            ),
                                            actions: [
                                              OutlineButton(
                                                onPressed: () => Navigator.pop(
                                                  dialogContext,
                                                ),
                                                child: const Text('Batal'),
                                              ),
                                              DestructiveButton(
                                                onPressed: () async {
                                                  Navigator.pop(dialogContext); // Tutup dialog
                                                  await authViewModel.logout();
                                                  if (context.mounted && !authViewModel.isAuthenticated) {
                                                    showToast(
                                                      context: context,
                                                      builder: (context, overlay) => ToastFormatter.success(
                                                        'Berhasil Keluar',
                                                        'Anda telah berhasil keluar dari akun.',
                                                      ),
                                                      location: ToastLocation.bottomRight,
                                                    );
                                                  }
                                                },
                                                child: const Text('Keluar'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      child: Row(
                                        children: [
                                          Icon(
                                            LucideIcons.logOut,
                                            size: 16,
                                            color: Theme.of(
                                              popoverContext,
                                            ).colorScheme.destructive,
                                          ),
                                          const Gap(8),
                                          Text(
                                            'Keluar',
                                            style: TextStyle(
                                              color: Theme.of(
                                                popoverContext,
                                              ).colorScheme.destructive,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
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
          ],
        ),
      ],
      child: Builder(
        builder: (context) {
          if (dashboardViewModel.isLoading) {
            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Aktivitas Pengeluaran').h4(),
                        const Gap(16),
                        const SizedBox(height: 150),
                      ],
                    ),
                  ).asSkeleton(),
                ),
                const Gap(24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tren Pengeluaran 30 Hari Terakhir').h4(),
                        const Gap(16),
                        const SizedBox(height: 200),
                      ],
                    ),
                  ).asSkeleton(),
                ),
                const Gap(24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Distribusi Pengeluaran').h4(),
                        const Gap(16),
                        const SizedBox(height: 200),
                      ],
                    ),
                  ).asSkeleton(),
                ),
              ],
            );
          } else if (dashboardViewModel.errorMessage != null) {
            return Center(
              child: Text(dashboardViewModel.errorMessage!).muted(),
            );
          } else if (dashboardViewModel.ringkasan != null) {
            final ringkasan = dashboardViewModel.ringkasan!;
            final now = DateTime.now();
            final monthNames = [
              'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
              'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
            ];
            final currentMonthName = monthNames[now.month - 1];

            // Hitung persentase pengeluaran
            int spendingPercent = 0;
            if (ringkasan.totalPemasukan > 0) {
              spendingPercent = ((ringkasan.totalPengeluaran / ringkasan.totalPemasukan) * 100).toInt();
            } else if (ringkasan.totalPengeluaran > 0 && ringkasan.saldo >= 0) {
              // Jika tidak ada pemasukan bulan ini tapi ada saldo, pakai (pengeluaran / (saldo+pengeluaran))
              spendingPercent = ((ringkasan.totalPengeluaran / (ringkasan.saldo + ringkasan.totalPengeluaran)) * 100).toInt();
            }

            return RefreshIndicator(
              onRefresh: () async {
                final now = DateTime.now();
                await context.read<DashboardViewModel>().initDashboard(
                  bulan: now.month,
                  tahun: now.year,
                );
              },
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // 1. Heatmap Calendar
                  if (dashboardViewModel.calendarData != null)
                    ExpenseHeatmapWidget(
                      calendarData: dashboardViewModel.calendarData!,
                    )
                  else
                    const SizedBox.shrink(),
                  const Gap(24),
                  // 2. Line Chart
                  const ExpenseLineChartWidget(),
                  const Gap(24),
                  // 3. Pie Chart
                  if (dashboardViewModel.kategoriData != null)
                    ExpensePieChartWidget(
                      kategoriData: dashboardViewModel.kategoriData!,
                    )
                  else
                    const SizedBox.shrink(),
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
