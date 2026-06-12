import 'package:flutter/material.dart' hide Switch, Scaffold, ScaffoldState, AppBar, CircularProgressIndicator, Column, Row, Divider, IconButton, Icon, Theme, Expanded, DropdownMenu, Card, Positioned, Stack, Chip;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../../domain/entities/preferensi_notifikasi.dart';
import '../cubit/notifikasi_list_cubit.dart';
import '../cubit/notifikasi_list_state.dart';
import 'notifikasi_form_page.dart';
import '../../../../injection_container.dart' as di;
import '../cubit/notifikasi_form_cubit.dart';

class NotifikasiIndexPage extends StatefulWidget {
  const NotifikasiIndexPage({super.key});

  @override
  State<NotifikasiIndexPage> createState() => _NotifikasiIndexPageState();
}

class _NotifikasiIndexPageState extends State<NotifikasiIndexPage> {
  @override
  void initState() {
    super.initState();
    context.read<NotifikasiListCubit>().fetchPreferensiList();
  }

  void _navigateToForm({PreferensiNotifikasi? preferensi}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => di.sl<NotifikasiFormCubit>(),
          child: NotifikasiFormPage(preferensiToEdit: preferensi),
        ),
      ),
    ).then((_) {
      if (mounted) {
        context.read<NotifikasiListCubit>().fetchPreferensiList();
      }
    });
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
    
    // Sort array before formatting
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
    return Scaffold(
      headers: [
        AppBar(
          title: const Text('Notifikasi Pengingat'),
        ),
      ],
      child: BlocConsumer<NotifikasiListCubit, NotifikasiListState>(
        listener: (context, state) {
          if (state is NotifikasiListActionSuccess) {
            showToast(
              context: context,
              builder: (context, overlay) {
                return SurfaceCard(
                  child: Basic(
                    title: const Text("Berhasil"),
                    subtitle: Text(state.message),
                  ),
                );
              },
            );
          } else if (state is NotifikasiListError) {
             showToast(
              context: context,
              builder: (context, overlay) {
                return SurfaceCard(
                  child: Basic(
                    title: const Text("Gagal"),
                    subtitle: Text(state.message),
                  ),
                );
              },
            );
          }
        },
        builder: (context, state) {
          if (state is NotifikasiListLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is NotifikasiListLoaded) {
            final list = state.preferensiList;
            
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
                                  onChanged: (val) {
                                    context.read<NotifikasiListCubit>().toggleAktif(item, val);
                                  },
                                ),
                                const SizedBox(width: 8),
                                IconButton.ghost(
                                  icon: const Icon(Icons.more_vert),
                                  onPressed: () {
                                    showDropdown(
                                      context: context,
                                      builder: (context) {
                                        return DropdownMenu(
                                          children: [
                                            MenuButton(
                                              onPressed: (context) => _navigateToForm(preferensi: item),
                                              child: const Text('Edit'),
                                            ),
                                            MenuButton(
                                              onPressed: (context) {
                                                context.read<NotifikasiListCubit>().deletePreferensi(item.id!);
                                              },
                                              child: const Text('Hapus'),
                                            ),
                                          ],
                                        );
                                      },
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
                    child: const Icon(Icons.add),
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
