import 'package:flutter/material.dart' hide Switch, Checkbox, Scaffold, ScaffoldState, AppBar, CircularProgressIndicator, Column, Row, Divider, IconButton, Icon, Theme, Expanded, DropdownMenu, Card, Positioned, Stack, Chip, ButtonStyle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' hide TimeOfDay;
import '../../domain/entities/preferensi_notifikasi.dart';
import '../cubit/notifikasi_form_cubit.dart';
import '../cubit/notifikasi_form_state.dart';

class NotifikasiFormPage extends StatefulWidget {
  final PreferensiNotifikasi? preferensiToEdit;

  const NotifikasiFormPage({super.key, this.preferensiToEdit});

  @override
  State<NotifikasiFormPage> createState() => _NotifikasiFormPageState();
}

class _NotifikasiFormPageState extends State<NotifikasiFormPage> {
  final List<String> _hariAktif = [];
  bool _aktif = true;
  TimeOfDay _jamNotifikasi = const TimeOfDay(hour: 19, minute: 0);

  final List<Map<String, String>> _daftarHari = [
    {'id': '1', 'nama': 'Senin'},
    {'id': '2', 'nama': 'Selasa'},
    {'id': '3', 'nama': 'Rabu'},
    {'id': '4', 'nama': 'Kamis'},
    {'id': '5', 'nama': 'Jumat'},
    {'id': '6', 'nama': 'Sabtu'},
    {'id': '7', 'nama': 'Minggu'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.preferensiToEdit != null) {
      _hariAktif.addAll(widget.preferensiToEdit!.hariAktif);
      _aktif = widget.preferensiToEdit!.aktif;
      
      final parts = widget.preferensiToEdit!.jamNotifikasi.split(':');
      if (parts.length == 2) {
        _jamNotifikasi = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 19,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
    } else {
      // Default new
      _hariAktif.addAll(['1', '2', '3', '4', '5']);
    }
  }

  void _simpan() {
    if (_hariAktif.isEmpty) {
      showToast(
        context: context,
        builder: (context, overlay) {
          return const SurfaceCard(
            child: Basic(
              title: Text("Peringatan"),
              subtitle: Text("Pilih minimal satu hari aktif!"),
            ),
          );
        },
      );
      return;
    }

    final jamStr = '${_jamNotifikasi.hour.toString().padLeft(2, '0')}:${_jamNotifikasi.minute.toString().padLeft(2, '0')}';
    
    final data = PreferensiNotifikasi(
      id: widget.preferensiToEdit?.id,
      hariAktif: _hariAktif,
      jamNotifikasi: jamStr,
      aktif: _aktif,
    );

    context.read<NotifikasiFormCubit>().simpanPreferensi(data);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.preferensiToEdit != null;

    return Scaffold(
      headers: [
        AppBar(
          leading: [
            IconButton.ghost(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
          title: Text(isEdit ? 'Edit Pengingat' : 'Tambah Pengingat'),
        ),
      ],
      child: BlocConsumer<NotifikasiFormCubit, NotifikasiFormState>(
        listener: (context, state) {
          if (state is NotifikasiFormSuccess) {
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
            Navigator.of(context).pop();
          } else if (state is NotifikasiFormError) {
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
          final isLoading = state is NotifikasiFormLoading;

          return ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Waktu Pengingat',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        PrimaryButton(
                          onPressed: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: _jamNotifikasi,
                            );
                            if (picked != null) {
                              setState(() {
                                _jamNotifikasi = picked;
                              });
                            }
                          },
                          child: Text(
                            '${_jamNotifikasi.hour.toString().padLeft(2, '0')}:${_jamNotifikasi.minute.toString().padLeft(2, '0')}',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Ulangi pada hari',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: _daftarHari.map((hari) {
                        final isSelected = _hariAktif.contains(hari['id']);
                        return Button(
                          style: isSelected ? const ButtonStyle.primary() : const ButtonStyle.outline(),
                          onPressed: () {
                            setState(() {
                              if (isSelected) {
                                _hariAktif.remove(hari['id']);
                              } else {
                                _hariAktif.add(hari['id']!);
                              }
                            });
                          },
                          child: Text(hari['nama']!),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Aktifkan Pengingat Ini',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        Switch(
                          value: _aktif,
                          onChanged: (val) {
                            setState(() {
                              _aktif = val;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                onPressed: isLoading ? null : _simpan,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Simpan Jadwal'),
              ),
            ],
          );
        },
      ),
    );
  }
}
