import 'package:flutter/material.dart' show RefreshIndicator, MaterialPageRoute;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:provider/provider.dart';
import 'package:snap_notes_mvvm/core/di/injection.dart';
import 'package:snap_notes_mvvm/features/pemasukan/viewmodels/pemasukan_viewmodel.dart';
import 'package:snap_notes_mvvm/features/pemasukan/views/pages/pemasukan_detail_page.dart';
import 'package:snap_notes_mvvm/features/pemasukan/views/pages/pemasukan_form_page.dart';
import 'package:snap_notes_mvvm/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:intl/intl.dart';

class PemasukanPage extends StatelessWidget {
  const PemasukanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final now = DateTime.now();
        return getIt<PemasukanViewModel>()
          ..loadPemasukan(bulan: now.month, tahun: now.year);
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
                  context.read<PemasukanViewModel>().loadPemasukan(
                    bulan: now.month,
                    tahun: now.year,
                  );
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
                      context.read<PemasukanViewModel>().loadPemasukan(
                        bulan: now.month,
                        tahun: now.year,
                      );
                    },
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          } else {
            return RefreshIndicator(
              onRefresh: () async {
                final now = DateTime.now();
                context.read<PemasukanViewModel>().loadPemasukan(
                  bulan: now.month,
                  tahun: now.year,
                );
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: viewModel.pemasukanList.isEmpty 
                  ? 2 
                  : viewModel.pemasukanList.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    final isGoodTrending = viewModel.percentageChange >= 0;
                    final percentageText = '${viewModel.percentageChange > 0 ? '+' : ''}${viewModel.percentageChange.toStringAsFixed(1)}%';
                    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24),
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
                                          Icon(LucideIcons.trendingUp, size: 14, color: Theme.of(context).colorScheme.primary),
                                          const Gap(4),
                                          Text(percentageText),
                                        ],
                                      ),
                                    )
                                  : DestructiveBadge(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(LucideIcons.trendingDown, size: 14),
                                          const Gap(4),
                                          Text(percentageText),
                                        ],
                                      ),
                                    ),
                              ],
                            ),
                            const Gap(16),
                            Text(currencyFormat.format(viewModel.totalCurrentMonth)).h3(),
                            const Gap(12),
                            Row(
                              children: [
                                Text('Trending ${isGoodTrending ? 'good' : 'bad'} this month').small(),
                                const Gap(8),
                                Icon(
                                  isGoodTrending ? LucideIcons.trendingUp : LucideIcons.trendingDown,
                                  size: 16,
                                ),
                              ],
                            ),
                            const Gap(4),
                            Text('$percentageText since last month').small().muted(),
                          ],
                        ),
                      ),
                    );
                  }

                  if (viewModel.pemasukanList.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 48),
                      child: Center(
                        child: const Text('Belum ada riwayat pemasukan untuk bulan ini.').muted().small(),
                      ),
                    );
                  }

                  final pemasukan = viewModel.pemasukanList[index - 1];
                  final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Card(
                      padding: const EdgeInsets.all(16),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () async {
                          final result = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PemasukanDetailPage(
                                pemasukanId: pemasukan.id,
                              ),
                            ),
                          );
                          if (result == true && context.mounted) {
                            final now = DateTime.now();
                            context.read<PemasukanViewModel>().loadPemasukan(
                              bulan: now.month,
                              tahun: now.year,
                            );
                          }
                        },
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(pemasukan.deskripsi).base(),
                                  Text(pemasukan.kategoriNama ?? 'Lainnya').muted(),
                                  const Gap(8),
                                  Text(
                                    '${pemasukan.tanggal.day}/${pemasukan.tanggal.month}/${pemasukan.tanggal.year}',
                                  ).small(),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(currencyFormat.format(pemasukan.jumlah)).base(),
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
