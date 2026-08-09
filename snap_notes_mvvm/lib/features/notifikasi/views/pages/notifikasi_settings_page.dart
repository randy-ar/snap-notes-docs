import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:provider/provider.dart';
import 'package:snap_notes_mvvm/core/utils/toast_formatter.dart';
import 'package:snap_notes_mvvm/features/notifikasi/models/preferensi_notifikasi.dart';
import 'package:snap_notes_mvvm/features/notifikasi/viewmodels/notifikasi_viewmodel.dart';
import 'package:snap_notes_mvvm/features/notifikasi/views/pages/notifikasi_form_page.dart';

class NotifikasiSettingsPage extends StatefulWidget {
  const NotifikasiSettingsPage({super.key});

  @override
  State<NotifikasiSettingsPage> createState() => _NotifikasiSettingsPageState();
}

class _NotifikasiSettingsPageState extends State<NotifikasiSettingsPage> {
  @override
  void initState() {
    super.initState();
    // Init notifications and load preferences after frame
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        final viewModel = context.read<NotifikasiViewModel>();
        await viewModel.init();
        await viewModel.loadPreferensi();
        // Schedule notifications after loading preferences
        if (mounted && viewModel.preferensiList.isNotEmpty) {
          await viewModel.scheduleNotifications(viewModel.preferensiList);
        }
      }
    });
  }

  void _navigateToForm({PreferensiNotifikasi? preferensi}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: context.read<NotifikasiViewModel>(),
          child: NotifikasiFormPage(preferensiToEdit: preferensi),
        ),
      ),
    ).then((_) async {
      if (mounted) {
        final viewModel = context.read<NotifikasiViewModel>();
        await viewModel.loadPreferensi();
        // Reschedule after returning from form
        if (mounted && viewModel.preferensiList.isNotEmpty) {
          await viewModel.scheduleNotifications(viewModel.preferensiList);
        }
      }
    });
  }

  Future<void> _deletePreferensi(String id) async {
    final viewModel = context.read<NotifikasiViewModel>();
    await viewModel.deletePreferensi(id);

    if (!mounted) return;

    if (viewModel.errorMessage != null) {
      _showToastError('Gagal menghapus preferensi', viewModel.errorMessage!);
    } else {
      _showToastSuccess('Preferensi berhasil dihapus');
      // Reschedule after delete
      if (viewModel.preferensiList.isNotEmpty) {
        await viewModel.scheduleNotifications(viewModel.preferensiList);
      }
    }
  }

  void _showDeleteConfirmation(BuildContext context, PreferensiNotifikasi item) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Preferensi'),
        content: Text('Apakah Anda yakin ingin menghapus jadwal jam ${item.jamNotifikasi}?'),
        actions: [
          OutlineButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          DestructiveButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _deletePreferensi(item.id!);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _showToastError(String message, String description) {
    showToast(
      context: context,
      builder: (context, overlay) => ToastFormatter.error(message, description),
      location: ToastLocation.bottomRight,
    );
  }

  void _showToastSuccess(String message) {
    showToast(
      context: context,
      builder: (context, overlay) => ToastFormatter.success(message),
      location: ToastLocation.bottomRight,
    );
  }

  String _formatHariAktif(List<String> hariStr) {
    if (hariStr.isEmpty) return 'Tidak ada jadwal';

    final daysMap = {
      '1': 'Senin',
      '2': 'Selasa',
      '3': 'Rabu',
      '4': 'Kamis',
      '5': 'Jumat',
      '6': 'Sabtu',
      '7': 'Minggu',
    };

    final sorted = List<String>.from(hariStr)..sort((a, b) => int.parse(a).compareTo(int.parse(b)));

    if (sorted.length == 7) return 'Setiap Hari';
    if (sorted.length == 5 &&
        sorted.contains('1') && sorted.contains('2') &&
        sorted.contains('3') && sorted.contains('4') && sorted.contains('5')) {
      return 'Hari Kerja';
    }
    if (sorted.length == 2 && sorted.contains('6') && sorted.contains('7')) {
      return 'Akhir Pekan';
    }

    return sorted.map((d) => daysMap[d] ?? d).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<NotifikasiViewModel>();

    return Scaffold(
      headers: [
        AppBar(
          title: const Text('Notifikasi Pengingat'),
          leading: [
            IconButton.ghost(
              icon: const Icon(LucideIcons.arrowLeft),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ],
      child: Builder(
        builder: (context) {
          if (viewModel.isLoading && viewModel.preferensiList.isEmpty) {
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: 3,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return Card(
                  child: Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '19:00',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Setiap Hari',
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Switch(
                            value: true,
                            onChanged: (_) {},
                          ),
                          const SizedBox(width: 8),
                          IconButton.ghost(
                            icon: const Icon(Icons.more_vert),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ).asSkeleton();
              },
            );
          }

          final list = viewModel.preferensiList;

          return Stack(
            children: [
              if (list.isEmpty)
                Center(
                  child: Text(
                    'Belum ada jadwal pengingat yang ditambahkan.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.mutedForeground,
                    ),
                  ),
                )
              else
                ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = list[index];
                    return Card(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.jamNotifikasi,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatHariAktif(item.hariAktif),
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.mutedForeground,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Switch(
                                value: item.aktif,
                                onChanged: (val) async {
                                  final viewModel = context.read<NotifikasiViewModel>();
                                  final updated = PreferensiNotifikasi(
                                    id: item.id,
                                    hariAktif: item.hariAktif,
                                    jamNotifikasi: item.jamNotifikasi,
                                    aktif: val,
                                  );
                                  await viewModel.updatePreferensi(item.id!, updated);
                                  // Reschedule after toggle
                                  if (mounted && viewModel.preferensiList.isNotEmpty) {
                                    await viewModel.scheduleNotifications(viewModel.preferensiList);
                                  }
                                },
                              ),
                              const SizedBox(width: 8),
                              IconButton.ghost(
                                icon: const Icon(Icons.more_vert),
                                onPressed: () {
                                  showDropdown(
                                    context: context,
                                    builder: (dropdownContext) => DropdownMenu(
                                      children: [
                                        MenuButton(
                                          onPressed: (_) {
                                            closeOverlay(dropdownContext);
                                            _navigateToForm(preferensi: item);
                                          },
                                          child: const Text('Edit'),
                                        ),
                                        MenuButton(
                                          onPressed: (_) {
                                            closeOverlay(dropdownContext);
                                            _showDeleteConfirmation(context, item);
                                          },
                                          child: const Text('Hapus'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              Positioned(
                bottom: 24,
                right: 24,
                child: PrimaryButton(
                  shape: ButtonShape.circle,
                  onPressed: () => _navigateToForm(),
                  child: const Icon(LucideIcons.plus),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
