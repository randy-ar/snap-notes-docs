import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart' show MaterialPageRoute;
import 'package:snap_notes/injection_container.dart';
import 'package:snap_notes/features/pengeluaran/presentation/cubit/pengeluaran_detail_cubit.dart';
import 'package:snap_notes/features/pengeluaran/presentation/cubit/pengeluaran_form_cubit.dart';
import 'package:snap_notes/features/pengeluaran/presentation/pages/pengeluaran_form_page.dart';

class PengeluaranDetailPage extends StatelessWidget {
  final String pengeluaranId;

  const PengeluaranDetailPage({
    super.key,
    required this.pengeluaranId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PengeluaranDetailCubit>()..fetchPengeluaranDetail(pengeluaranId),
      child: const PengeluaranDetailView(),
    );
  }
}

class PengeluaranDetailView extends StatelessWidget {
  const PengeluaranDetailView({super.key});

  @override
  Widget build(BuildContext context) {
      return BlocConsumer<PengeluaranDetailCubit, PengeluaranDetailState>(
        listener: (context, state) {
          if (state is PengeluaranDetailDeleted) {
            showToast(
              context: context,
              builder: (context, overlay) => SurfaceCard(
                child: const Basic(
                  title: Text('Berhasil'),
                  subtitle: Text('Pengeluaran berhasil dihapus'),
                ),
              ),
              location: ToastLocation.bottomRight,
            );
            Navigator.pop(context, true); // Return true to indicate deletion
          } else if (state is PengeluaranDetailError) {
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
          if (state is PengeluaranDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PengeluaranDetailError) {
            return Center(child: Text(state.message).muted());
          } else if (state is PengeluaranDetailLoaded) {
            final p = state.pengeluaran;
            final isOcr = p.struk != null;
            
            return Scaffold(
              headers: [
                AppBar(
                  title: const Text('Detail Pengeluaran'),
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
                              create: (_) => sl<PengeluaranFormCubit>(),
                              child: PengeluaranFormPage(pengeluaran: p),
                            ),
                          ),
                        );
                        if (result == true && context.mounted) {
                          context.read<PengeluaranDetailCubit>().fetchPengeluaranDetail(p.id!);
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
                            title: const Text('Hapus Pengeluaran'),
                            content: const Text('Apakah Anda yakin ingin menghapus pengeluaran ini?'),
                            actions: [
                              OutlineButton(
                                onPressed: () => Navigator.pop(dialogContext),
                                child: const Text('Batal'),
                              ),
                              DestructiveButton(
                                onPressed: () {
                                  Navigator.pop(dialogContext);
                                  context.read<PengeluaranDetailCubit>().deletePengeluaran(p.id!);
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

                      if (!isOcr && p.catatan != null && p.catatan!.isNotEmpty) ...[
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

                      if (isOcr) ...[
                        Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Item Belanja').small().bold(),
                              const Gap(16),
                              if (p.struk!.items.isNotEmpty)
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: p.struk!.items.length,
                                  separatorBuilder: (_, __) => const Gap(8),
                                  itemBuilder: (context, index) {
                                    final item = p.struk!.items[index];
                                    return Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(item.name),
                                              Text(
                                                '${item.quantity} x Rp ${item.price.toStringAsFixed(0)}',
                                              ).small().muted(),
                                            ],
                                          ),
                                        ),
                                        Text('Rp ${item.totalPrice.toStringAsFixed(0)}'),
                                      ],
                                    );
                                  },
                                )
                              else
                                const Text('Tidak ada item belanja').italic().muted(),
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

                      if (isOcr) ...[
                        const Gap(24),
                        const Text('Gambar Struk').large().bold(),
                        const Gap(16),
                        Card(
                          child: p.struk!.imageUrl != null
                              ? Image.network(
                                  p.struk!.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Text('Gagal memuat gambar'),
                                    ),
                                  ),
                                )
                              : const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(32.0),
                                    child: Text('Gambar struk tidak tersedia'),
                                  ),
                                ),
                        ),
                      ]
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
