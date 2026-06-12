import 'package:flutter/material.dart' show RefreshIndicator, MaterialPageRoute;
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:snap_notes_mvvm/core/di/injection.dart';
import 'package:snap_notes_mvvm/features/pengeluaran/viewmodels/pengeluaran_viewmodel.dart';
import 'package:snap_notes_mvvm/features/pengeluaran/views/pages/pengeluaran_form_page.dart';

class PengeluaranDetailPage extends StatelessWidget {
  final String pengeluaranId;

  const PengeluaranDetailPage({
    super.key,
    required this.pengeluaranId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<PengeluaranViewModel>()..loadPengeluaranDetail(pengeluaranId),
      child: PengeluaranDetailView(pengeluaranId: pengeluaranId),
    );
  }
}

class PengeluaranDetailView extends StatelessWidget {
  final String pengeluaranId;

  const PengeluaranDetailView({super.key, required this.pengeluaranId});

  Future<void> _handleDelete(BuildContext context, PengeluaranViewModel viewModel) async {
    await viewModel.hapusPengeluaran(pengeluaranId);
    if (context.mounted) {
      if (viewModel.errorMessage != null) {
        showToast(
          context: context,
          builder: (context, overlay) => SurfaceCard(
            child: Basic(
              title: const Text('Gagal'),
              subtitle: Text(viewModel.errorMessage!),
            ),
          ),
          location: ToastLocation.bottomRight,
        );
      } else {
        showToast(
          context: context,
          builder: (context, overlay) => const SurfaceCard(
            child: Basic(
              title: Text('Berhasil'),
              subtitle: Text('Pengeluaran berhasil dihapus'),
            ),
          ),
          location: ToastLocation.bottomRight,
        );
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PengeluaranViewModel>();

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
            if (viewModel.pengeluaranDetail != null) ...[
              IconButton.ghost(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChangeNotifierProvider.value(
                        value: viewModel,
                        child: PengeluaranFormPage(pengeluaran: viewModel.pengeluaranDetail),
                      ),
                    ),
                  );
                  if (result == true && context.mounted) {
                    context.read<PengeluaranViewModel>().loadPengeluaranDetail(pengeluaranId);
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
                            _handleDelete(context, viewModel);
                          },
                          child: const Text('Hapus'),
                        ),
                      ],
                    ),
                  );
                },
                icon: Icon(LucideIcons.trash2, color: Theme.of(context).colorScheme.destructive),
              ),
            ]
          ],
        ),
      ],
      child: Builder(
        builder: (context) {
          if (viewModel.isLoading && viewModel.pengeluaranDetail == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null && viewModel.pengeluaranDetail == null) {
            return Center(child: Text(viewModel.errorMessage!).muted());
          }

          final p = viewModel.pengeluaranDetail;
          if (p == null) {
            return const Center(child: Text('Data pengeluaran tidak ditemukan'));
          }

          final isOcr = p.struk != null;

          return RefreshIndicator(
            onRefresh: () => context.read<PengeluaranViewModel>().loadPengeluaranDetail(pengeluaranId),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
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
                                separatorBuilder: (_, _) => const Gap(8),
                                itemBuilder: (context, index) {
                                  final item = p.struk!.items[index];
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(item.name).small().medium(),
                                            Text(
                                              '${item.quantity} x Rp ${item.price.toStringAsFixed(0)}',
                                            ).xSmall().muted(),
                                          ],
                                        ),
                                      ),
                                      Text('Rp ${item.totalPrice.toStringAsFixed(0)}').small().semiBold(),
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

                    if (isOcr && p.struk!.imageUrl != null) ...[
                      const Gap(24),
                      const Text('Gambar Struk').large().bold(),
                      const Gap(16),
                      Card(
                        padding: EdgeInsets.zero,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            p.struk!.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text('Gagal memuat gambar'),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
