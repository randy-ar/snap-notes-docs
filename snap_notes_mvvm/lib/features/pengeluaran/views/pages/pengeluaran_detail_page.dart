import 'package:flutter/material.dart' show RefreshIndicator, MaterialPageRoute;
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:snap_notes_mvvm/core/di/injection.dart';
import 'package:snap_notes_mvvm/core/utils/toast_formatter.dart';
import 'package:snap_notes_mvvm/features/pengeluaran/viewmodels/pengeluaran_viewmodel.dart';
import 'package:snap_notes_mvvm/features/pengeluaran/views/pages/pengeluaran_form_page.dart';
import 'package:snap_notes_mvvm/features/receipt/models/receipt.dart';
import 'package:snap_notes_mvvm/features/receipt/views/pages/full_screen_image_page.dart';
import 'package:snap_notes_mvvm/utils/format_utils.dart';

class PengeluaranDetailPage extends StatelessWidget {
  final String pengeluaranId;
  final bool? isOcr;

  const PengeluaranDetailPage({
    super.key,
    required this.pengeluaranId,
    this.isOcr,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<PengeluaranViewModel>()..loadPengeluaranDetail(pengeluaranId),
      child: PengeluaranDetailView(pengeluaranId: pengeluaranId, isOcr: isOcr),
    );
  }
}

class PengeluaranDetailView extends StatelessWidget {
  final String pengeluaranId;
  final bool? isOcr;

  const PengeluaranDetailView({
    super.key,
    required this.pengeluaranId,
    this.isOcr,
  });

  Future<void> _handleDelete(BuildContext context, PengeluaranViewModel viewModel) async {
    await viewModel.hapusPengeluaran(pengeluaranId);
    if (context.mounted) {
      if (viewModel.errorMessage != null) {
        showToast(
          context: context,
          builder: (context, overlay) => ToastFormatter.error('Gagal menghapus pengeluaran', viewModel.errorMessage!),
          location: ToastLocation.bottomRight,
        );
      } else {
        showToast(
          context: context,
          builder: (context, overlay) => ToastFormatter.success('Pengeluaran berhasil dihapus'),
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
            final showOcrSkeleton = isOcr ?? true;
            if (showOcrSkeleton) {
              return SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        padding: EdgeInsets.zero,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            height: 300,
                            color: Theme.of(context).colorScheme.muted,
                          ).asSkeleton(),
                        ),
                      ).asSkeleton(),
                      const Gap(24),
                      Card(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: const Text('Nama Toko Belanja').large().bold(),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.muted,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text('Kategori'),
                                ),
                              ],
                            ),
                            const Gap(8),
                            Row(
                              children: [
                                const Icon(LucideIcons.calendar, size: 16),
                                const Gap(8),
                                const Text('DD/MM/YYYY').small(),
                              ],
                            ),
                            const Gap(24),
                            const Divider(),
                            const Gap(16),
                            const Text('Item Belanja').small().semiBold(),
                            const Gap(12),
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: 2,
                              separatorBuilder: (_, _) => const Gap(8),
                              itemBuilder: (context, index) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('Nama barang belanjaan').small().medium(),
                                          const Text('1 x Rp 10.000').xSmall().muted(),
                                        ],
                                      ),
                                    ),
                                    const Text('Rp 10.000').small().semiBold(),
                                  ],
                                );
                              },
                            ),
                            const Gap(16),
                            const Divider(),
                            const Gap(16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total').small().semiBold(),
                                const Text('Rp 100.000').small().semiBold(),
                              ],
                            ),
                          ],
                        ),
                      ).asSkeleton(),
                    ],
                  ),
                ),
              );
            } else {
              return SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text('Deskripsi Pengeluaran yang Sangat Panjang Sekali').large().bold(),
                          const Gap(4),
                          const Text('23 June 2026').small().muted(),
                          const Gap(8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: const PrimaryBadge(child: Text('Kategori Pengeluaran')),
                          ),
                        ],
                      ).asSkeleton(),
                      const Gap(24),
                      Card(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total').large().bold(),
                            const Text('Rp 100.000').large().bold(),
                          ],
                        ),
                      ).asSkeleton(),
                    ],
                  ),
                ),
              );
            }
          }

          if (viewModel.errorMessage != null && viewModel.pengeluaranDetail == null) {
            return Center(child: Text(viewModel.errorMessage!).muted());
          }

          final p = viewModel.pengeluaranDetail;
          if (p == null) {
            return const Center(child: Text('Data pengeluaran tidak ditemukan'));
          }

          final hasImage = p.struk?.imageUrl != null && p.struk!.imageUrl!.isNotEmpty;
          final isStrukDetail = p.struk != null || hasImage;

          if (isStrukDetail) {
            return RefreshIndicator(
              onRefresh: () => context.read<PengeluaranViewModel>().loadPengeluaranDetail(pengeluaranId),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasImage) ...[
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FullScreenImagePage(
                                imageUrl: p.struk!.imageUrl!,
                                title: 'Foto Struk',
                              ),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Hero(
                            tag: p.struk!.imageUrl!,
                            child: Image.network(
                              p.struk!.imageUrl!,
                              width: double.infinity,
                              fit: BoxFit.fitWidth,
                              errorBuilder: (context, error, stackTrace) => Container(
                                height: 200,
                                color: Theme.of(context).colorScheme.muted,
                                child: Center(
                                  child: Icon(LucideIcons.imageOff, color: Theme.of(context).colorScheme.mutedForeground, size: 48),
                                ),
                              ),
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  height: 300,
                                  color: Theme.of(context).colorScheme.muted,
                                  child: const Center(child: CircularProgressIndicator()),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      const Gap(24),
                    ],
                    Card(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(p.deskripsi).large().bold(),
                              ),
                              if (p.kategoriNama != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.muted,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(p.kategoriNama!).xSmall(),
                                ),
                            ],
                          ),
                          const Gap(8),
                          Row(
                            children: [
                              Icon(LucideIcons.calendar, size: 16, color: Theme.of(context).colorScheme.mutedForeground),
                              const Gap(8),
                              Text(FormatUtils.formatIndonesianDate(p.tanggal)).small().muted(),
                            ],
                          ),
                          const Gap(24),
                          const Divider(),
                          const Gap(16),
                          const Text('Item Belanja').small().semiBold(),
                          const Gap(12),
                          if (p.struk != null && p.struk!.items.isNotEmpty)
                            ...p.struk!.items.map((item) => _buildItemRow(context, item))
                          else
                            const Text('Tidak ada item belanja').italic().muted().small(),
                          if (p.struk != null && p.struk!.discount != null && p.struk!.discount! > 0) ...[
                            const Gap(8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Diskon').small().medium(),
                                Text(
                                  FormatUtils.formatRupiah(p.struk!.discount!),
                                  style: Theme.of(context).typography.small.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const Gap(16),
                          const Divider(),
                          const Gap(16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total').small().semiBold(),
                              Text(FormatUtils.formatRupiah(p.jumlah)).small().semiBold(),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (p.catatan != null && p.catatan!.isNotEmpty) ...[
                      const Gap(16),
                      SizedBox(
                        width: double.infinity,
                        child: Card(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Catatan').small().bold(),
                              const Gap(8),
                              Text(p.catatan!),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }

          // Layout Pengeluaran Biasa (Input Manual)
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
                    Text(FormatUtils.formatIndonesianDate(p.tanggal)).small().muted(),
                    if (p.kategoriNama != null) ...[
                      const Gap(8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: PrimaryBadge(child: Text(p.kategoriNama!)),
                      ),
                    ],
                    const Gap(24),

                    if (p.catatan != null && p.catatan!.isNotEmpty) ...[
                      SizedBox(
                        width: double.infinity,
                        child: Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Catatan').small().bold(),
                              const Gap(8),
                              Text(p.catatan!),
                            ],
                          ),
                        ),
                      ),
                      const Gap(16),
                    ],

                    Card(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total').large().bold(),
                          Text(FormatUtils.formatRupiah(p.jumlah)).large().bold(),
                        ],
                      ),
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

  Widget _buildItemRow(BuildContext context, ReceiptItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name).small().medium(),
                    if (item.categoryName != null)
                      Text(item.categoryName!).xSmall().muted(),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  '${item.quantity} x ${FormatUtils.formatRupiah(item.price)}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).typography.xSmall.copyWith(
                    color: Theme.of(context).colorScheme.mutedForeground,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  FormatUtils.formatRupiah(item.totalPrice),
                  textAlign: TextAlign.right,
                  style: Theme.of(context).typography.small.copyWith(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          if (item.discount != null && item.discount! > 0)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Diskon: -${FormatUtils.formatRupiah(item.discount!)}',
                    style: Theme.of(context).typography.xSmall.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
