import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:provider/provider.dart';
import 'package:snap_notes_mvvm/core/di/injection.dart';
import 'package:snap_notes_mvvm/core/utils/toast_formatter.dart';
import 'package:snap_notes_mvvm/features/pemasukan/viewmodels/pemasukan_viewmodel.dart';
import 'package:snap_notes_mvvm/features/pemasukan/views/pages/pemasukan_form_page.dart';
import 'package:snap_notes_mvvm/utils/format_utils.dart';

class PemasukanDetailPage extends StatefulWidget {
  final String pemasukanId;

  const PemasukanDetailPage({
    super.key,
    required this.pemasukanId,
  });

  @override
  State<PemasukanDetailPage> createState() => _PemasukanDetailPageState();
}

class _PemasukanDetailPageState extends State<PemasukanDetailPage> {
  late PemasukanViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<PemasukanViewModel>();
    _viewModel.getPemasukanDetail(widget.pemasukanId);
  }

  @override
  void dispose() {
    // ViewModel is typically closed by Provider if provided up the tree,
    // but here we are managing our own instance.
    _viewModel.dispose();
    super.dispose();
  }

  void _showDeleteDialog(BuildContext context) {
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
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _viewModel.hapusPemasukan(widget.pemasukanId);
              
              if (!mounted) return;
              
              if (_viewModel.errorMessage != null) {
                _showErrorToast(_viewModel.errorMessage!);
              } else {
                _showSuccessToast('Pemasukan berhasil dihapus');
                Navigator.pop(context, true);
              }
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _showErrorToast(String message) {
    showToast(
      context: context,
      builder: (context, overlay) => ToastFormatter.error('Gagal', message),
      location: ToastLocation.bottomRight,
    );
  }

  void _showSuccessToast(String message) {
    showToast(
      context: context,
      builder: (context, overlay) => ToastFormatter.success(message),
      location: ToastLocation.bottomRight,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
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
              Consumer<PemasukanViewModel>(
                builder: (context, viewModel, child) {
                  if (viewModel.pemasukanDetail != null && !viewModel.isLoading) {
                    final p = viewModel.pemasukanDetail!;
                    return Row(
                      children: [
                        IconButton.ghost(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChangeNotifierProvider(
                                  create: (_) => getIt<PemasukanViewModel>(),
                                  child: PemasukanFormPage(pemasukan: p),
                                ),
                              ),
                            );
                            if (result == true && context.mounted) {
                              _viewModel.getPemasukanDetail(widget.pemasukanId);
                            }
                          },
                          icon: const Icon(LucideIcons.pencil, size: 20),
                        ),
                        const Gap(8),
                        IconButton.ghost(
                          onPressed: () => _showDeleteDialog(context),
                          icon: Icon(
                            LucideIcons.trash2,
                            color: Theme.of(context).colorScheme.destructive,
                          ),
                        ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ],
        child: Consumer<PemasukanViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (viewModel.errorMessage != null && viewModel.pemasukanDetail == null) {
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
                    Text(viewModel.errorMessage!).muted(),
                    const Gap(16),
                    PrimaryButton(
                      onPressed: () => _viewModel.getPemasukanDetail(widget.pemasukanId),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              );
            } else if (viewModel.pemasukanDetail != null) {
              final p = viewModel.pemasukanDetail!;
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(p.deskripsi).large().bold(),
                      const Gap(4),
                      Text(FormatUtils.formatIndonesianDate(p.tanggal))
                          .small()
                          .muted(),
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
                            Text(FormatUtils.formatRupiah(p.jumlah)).large().bold(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

