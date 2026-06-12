import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart' show MaterialPageRoute;
import 'package:snap_notes/injection_container.dart';
import 'package:snap_notes/features/pemasukan/presentation/cubit/pemasukan_detail_cubit.dart';
import 'package:snap_notes/features/pemasukan/presentation/cubit/pemasukan_form_cubit.dart';
import 'package:snap_notes/features/pemasukan/presentation/pages/pemasukan_form_page.dart';

class PemasukanDetailPage extends StatelessWidget {
  final String pemasukanId;

  const PemasukanDetailPage({
    super.key,
    required this.pemasukanId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PemasukanDetailCubit>()..fetchPemasukanDetail(pemasukanId),
      child: const PemasukanDetailView(),
    );
  }
}

class PemasukanDetailView extends StatelessWidget {
  const PemasukanDetailView({super.key});

  @override
  Widget build(BuildContext context) {
      return BlocConsumer<PemasukanDetailCubit, PemasukanDetailState>(
        listener: (context, state) {
          if (state is PemasukanDetailDeleted) {
            showToast(
              context: context,
              builder: (context, overlay) => SurfaceCard(
                child: const Basic(
                  title: Text('Berhasil'),
                  subtitle: Text('Pemasukan berhasil dihapus'),
                ),
              ),
              location: ToastLocation.bottomRight,
            );
            Navigator.pop(context, true); // Return true to indicate deletion
          } else if (state is PemasukanDetailError) {
            showToast(
              context: context,
              builder: (context, overlay) => SurfaceCard(
                child: Basic(
                  title: const Text('Gagal'),
                  subtitle: Text(state.message),
                ),
              ),
              location: ToastLocation.bottomRight,
            );
          }
        },
        builder: (context, state) {
          if (state is PemasukanDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PemasukanDetailError) {
            return Center(child: Text(state.message).muted());
          } else if (state is PemasukanDetailLoaded) {
            final p = state.pemasukan;

            return Scaffold(
              headers: [
                AppBar(
                  title: const Text('Detail Pemasukan'),
                  leading: [
                    IconButton.ghost(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(LucideIcons.arrowLeft),
                    ),
                  ],
                  trailing: [
                    IconButton.ghost(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider(
                              create: (_) => sl<PemasukanFormCubit>(),
                              child: PemasukanFormPage(pemasukan: p),
                            ),
                          ),
                        );
                        if (result == true && context.mounted) {
                          context.read<PemasukanDetailCubit>().fetchPemasukanDetail(p.id);
                        }
                      },
                      icon: const Icon(LucideIcons.pencil, size: 20),
                    ),
                    const Gap(8),
                    IconButton.ghost(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            title: const Text('Hapus Pemasukan'),
                            content: const Text('Apakah Anda yakin ingin menghapus pemasukan ini?'),
                            actions: [
                              OutlineButton(
                                onPressed: () => Navigator.pop(dialogContext),
                                child: const Text('Batal'),
                              ),
                              DestructiveButton(
                                onPressed: () {
                                  Navigator.pop(dialogContext);
                                  context.read<PemasukanDetailCubit>().deletePemasukan(p.id);
                                },
                                child: const Text('Hapus'),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: Icon(LucideIcons.trash2, color: Theme.of(context).colorScheme.destructive),
                    ),
                  ],
                ),
              ],
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(p.deskripsi).large().bold(),
                      const Gap(4),
                      Text('${p.tanggal.day}/${p.tanggal.month}/${p.tanggal.year}').small().muted(),
                      if (p.kategoriNama != null) ...[
                        const Gap(8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: PrimaryBadge(child: Text(p.kategoriNama!)),
                        ),
                      ],
                      const Gap(24),

                      if (p.catatan != null && p.catatan!.isNotEmpty) ...[
                        Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Catatan').small().bold(),
                              const Gap(8),
                              Text(p.catatan!),
                            ],
                          ),
                        ),
                        const Gap(16),
                      ],

                      Card(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total').large().bold(),
                            Text('Rp ${p.jumlah.toStringAsFixed(0)}').large().bold(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      );
  }
}
