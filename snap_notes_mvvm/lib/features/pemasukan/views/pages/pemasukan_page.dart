import 'package:flutter/material.dart' show RefreshIndicator, MaterialPageRoute;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:provider/provider.dart';
import 'package:snap_notes_mvvm/core/di/injection.dart';
import 'package:snap_notes_mvvm/features/pemasukan/viewmodels/pemasukan_viewmodel.dart';
import 'package:snap_notes_mvvm/features/pemasukan/views/pages/pemasukan_detail_page.dart';
import 'package:snap_notes_mvvm/features/pemasukan/views/pages/pemasukan_form_page.dart';
import 'package:snap_notes_mvvm/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:snap_notes_mvvm/features/pemasukan/models/pemasukan.dart';
import 'package:snap_notes_mvvm/utils/format_utils.dart';

class PemasukanPage extends StatelessWidget {
  const PemasukanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final now = DateTime.now();
        return getIt<PemasukanViewModel>()
          ..loadOverview(bulan: now.month, tahun: now.year)
          ..loadPemasukan(isRefresh: true);
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
                                                onPressed: () {
                                                  Navigator.pop(dialogContext);
                                                  authViewModel.logout();
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
          title: const Text('Pemasukan'),
          trailing: [
            IconButton.ghost(
              onPressed: () async {
                final vm = context.read<PemasukanViewModel>();
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider.value(
                      value: vm,
                      child: const PemasukanFormPage(),
                    ),
                  ),
                );
                if (result == true && context.mounted) {
                  final now = DateTime.now();
                  context.read<PemasukanViewModel>().loadOverview(
                    bulan: now.month,
                    tahun: now.year,
                  );
                  context.read<PemasukanViewModel>().loadPemasukan(isRefresh: true);
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
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 5,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Card(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total Pemasukan'),
                              SecondaryBadge(child: Text('+0.0%')),
                            ],
                          ),
                          const Gap(16),
                          const Text('Rp 000.000').h3(),
                          const Gap(12),
                          const Row(
                            children: [
                              Text('Trending good this month'),
                              Gap(8),
                              Icon(LucideIcons.trendingUp, size: 16),
                            ],
                          ),
                          const Gap(4),
                          const Text('since last month').small(),
                        ],
                      ),
                    ).asSkeleton(),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Card(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Nama Pemasukan'),
                              Text('Kategori'),
                              Gap(8),
                              Text('DD/MM/YYYY'),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Rp 000.000'),
                            const Gap(12),
                            Icon(
                              LucideIcons.chevronRight,
                              size: 16,
                              color: Theme.of(context).colorScheme.foreground,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ).asSkeleton(),
                );
              },
            );
          } else if (viewModel.errorMessage != null &&
              viewModel.pemasukanList.isEmpty) {
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
                      context.read<PemasukanViewModel>().loadOverview(
                        bulan: now.month,
                        tahun: now.year,
                      );
                      context.read<PemasukanViewModel>().loadPemasukan(isRefresh: true);
                    },
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          } else {
            final flattenedItems = <dynamic>[];
            flattenedItems.add('OVERVIEW');

            int? currentMonth;
            int? currentYear;

            for (var p in viewModel.pemasukanList) {
              if (currentMonth != p.tanggal.month || currentYear != p.tanggal.year) {
                currentMonth = p.tanggal.month;
                currentYear = p.tanggal.year;
                flattenedItems.add({'month': currentMonth, 'year': currentYear});
              }
              flattenedItems.add(p);
            }

            return NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (!viewModel.isLoadingMore &&
                    viewModel.hasMoreData &&
                    scrollInfo.metrics.pixels >=
                        scrollInfo.metrics.maxScrollExtent - 200) {
                  viewModel.loadMorePemasukan();
                }
                return false;
              },
              child: RefreshIndicator(
                onRefresh: () async {
                  final now = DateTime.now();
                  context.read<PemasukanViewModel>().loadOverview(
                    bulan: now.month,
                    tahun: now.year,
                  );
                  await context.read<PemasukanViewModel>().loadPemasukan(isRefresh: true);
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: flattenedItems.length + (viewModel.hasMoreData ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == flattenedItems.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final item = flattenedItems[index];

                    if (item == 'OVERVIEW') {
                      final overview = viewModel.overviewData;
                      if (overview == null) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: const Card(
                            padding: EdgeInsets.all(16),
                            child: SizedBox(height: 120),
                          ).asSkeleton(),
                        );
                      }

                      final totalCurrentMonth = (overview['totalCurrentMonth'] as num).toDouble();
                      final percentageChange = (overview['percentageChange'] as num).toDouble();
                      final isGoodTrending = overview['isTrendingGood'] as bool;
                      final percentageText = '${percentageChange > 0 ? '+' : ''}${percentageChange.toStringAsFixed(1)}%';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Card(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Total Pemasukan').muted(),
                                  isGoodTrending
                                      ? SecondaryBadge(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                LucideIcons.trendingUp,
                                                size: 14,
                                                color: Theme.of(context).colorScheme.primary,
                                              ),
                                              const Gap(4),
                                              Text(percentageText),
                                            ],
                                          ),
                                        )
                                      : DestructiveBadge(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                LucideIcons.trendingDown,
                                                size: 14,
                                              ),
                                              const Gap(4),
                                              Text(percentageText),
                                            ],
                                          ),
                                        ),
                                ],
                              ),
                              const Gap(16),
                              Text(
                                FormatUtils.formatRupiah(totalCurrentMonth),
                              ).h3(),
                              const Gap(12),
                              Row(
                                children: [
                                  Text(
                                    'Tren pemasukan ${isGoodTrending ? 'membaik' : 'memburuk'} bulan ini',
                                  ).small(),
                                  const Gap(8),
                                  Icon(
                                    isGoodTrending ? LucideIcons.trendingUp : LucideIcons.trendingDown,
                                    size: 16,
                                  ),
                                ],
                              ),
                              const Gap(4),
                              Text(
                                '$percentageText dibanding bulan lalu',
                              ).small().muted(),
                            ],
                          ),
                        ),
                      );
                    }

                    if (item is Map<String, int?>) {
                      final monthNames = [
                        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
                        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
                      ];
                      final monthName = monthNames[(item['month'] ?? 1) - 1];
                      final year = item['year'];
                      return Padding(
                        padding: const EdgeInsets.only(top: 16.0, bottom: 8.0, left: 4.0),
                        child: Text('$monthName $year').small().muted().bold(),
                      );
                    }

                    final pemasukan = item as Pemasukan;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Card(
                        padding: const EdgeInsets.all(16),
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () async {
                            final vm = context.read<PemasukanViewModel>();
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChangeNotifierProvider(
                                  create: (_) => getIt<PemasukanViewModel>(),
                                  child: PemasukanDetailPage(
                                    pemasukanId: pemasukan.id,
                                  ),
                                ),
                              ),
                            );

                            if (result == true && context.mounted) {
                              final now = DateTime.now();
                              vm.loadOverview(
                                bulan: now.month,
                                tahun: now.year,
                              );
                              vm.loadPemasukan(isRefresh: true);
                            }
                          },
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(pemasukan.deskripsi).base(),
                                    Text(
                                      pemasukan.kategoriNama ?? 'Lainnya',
                                    ).muted(),
                                    const Gap(8),
                                    Text(
                                      FormatUtils.formatIndonesianDate(pemasukan.tanggal),
                                    ).small(),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    FormatUtils.formatRupiah(pemasukan.jumlah),
                                  ).base(),
                                  const Gap(12),
                                  Icon(
                                    LucideIcons.chevronRight,
                                    size: 16,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.foreground,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
