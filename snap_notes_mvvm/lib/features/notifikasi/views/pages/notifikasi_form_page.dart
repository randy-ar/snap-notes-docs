import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:provider/provider.dart';
import 'package:snap_notes_mvvm/core/utils/toast_formatter.dart';
import 'package:snap_notes_mvvm/features/notifikasi/models/preferensi_notifikasi.dart';
import 'package:snap_notes_mvvm/features/notifikasi/viewmodels/notifikasi_viewmodel.dart';

class NotifikasiFormPage extends StatefulWidget {
  final PreferensiNotifikasi? preferensiToEdit;

  const NotifikasiFormPage({super.key, this.preferensiToEdit});

  @override
  State<NotifikasiFormPage> createState() => _NotifikasiFormPageState();
}

class _NotifikasiFormPageState extends State<NotifikasiFormPage> {
  late TimeOfDay _selectedTime;
  final Set<String> _selectedDays = {};
  bool _aktif = true;
  bool _isSaving = false;

  final List<Map<String, String>> _days = [
    {'value': '1', 'label': 'Senin'},
    {'value': '2', 'label': 'Selasa'},
    {'value': '3', 'label': 'Rabu'},
    {'value': '4', 'label': 'Kamis'},
    {'value': '5', 'label': 'Jumat'},
    {'value': '6', 'label': 'Sabtu'},
    {'value': '7', 'label': 'Minggu'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.preferensiToEdit != null) {
      final parts = widget.preferensiToEdit!.jamNotifikasi.split(':');
      _selectedTime = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
      _selectedDays.addAll(widget.preferensiToEdit!.hariAktif);
      _aktif = widget.preferensiToEdit!.aktif;
    } else {
      _selectedTime = const TimeOfDay(hour: 19, minute: 0);
    }
  }

  Future<void> _save() async {
    if (_selectedDays.isEmpty) {
      _showToastValidation('Pilih minimal satu hari');
      return;
    }

    setState(() => _isSaving = true);

    final preferensi = PreferensiNotifikasi(
      id: widget.preferensiToEdit?.id,
      hariAktif: _selectedDays.toList()..sort(),
      jamNotifikasi: '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
      aktif: _aktif,
    );

    final viewModel = context.read<NotifikasiViewModel>();

    if (widget.preferensiToEdit != null) {
      await viewModel.updatePreferensi(widget.preferensiToEdit!.id!, preferensi);
    } else {
      await viewModel.createPreferensi(preferensi);
    }

    if (!mounted) return;
    
    setState(() => _isSaving = false);

    if (viewModel.errorMessage != null) {
      _showToastError('Gagal menyimpan pengingat', viewModel.errorMessage!);
    } else {
      _showToastSuccess(widget.preferensiToEdit != null ? 'Pengingat diperbarui' : 'Pengingat ditambahkan');
      Navigator.of(context).pop();
    }
  }

  void _showToastValidation(String message) {
    showToast(
      context: context,
      builder: (context, overlay) => ToastFormatter.validation(message),
      location: ToastLocation.bottomRight,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      headers: [
        AppBar(
          title: Text(widget.preferensiToEdit != null ? 'Edit Pengingat' : 'Tambah Pengingat'),
          leading: [
            IconButton.ghost(
              icon: const Icon(LucideIcons.arrowLeft),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ],
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Jam Notifikasi').h4(),
              const Gap(8),
              TimePicker(
                value: _selectedTime,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedTime = value;
                    });
                  }
                },
              ),
              const Gap(24),
              const Text('Hari Aktif').h4(),
              const Gap(8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _days.map<Widget>((day) {
                  final isSelected = _selectedDays.contains(day['value']);
                  return isSelected
                    ? PrimaryButton(
                        onPressed: () {
                          setState(() {
                            _selectedDays.remove(day['value']);
                          });
                        },
                        child: Text(day['label']!),
                      )
                    : OutlineButton(
                        onPressed: () {
                          setState(() {
                            _selectedDays.add(day['value']!);
                          });
                        },
                        child: Text(day['label']!),
                      );
                }).toList(),
              ),
              const Gap(24),
              Row(
                children: [
                  const Text('Aktif').h4(),
                  const Spacer(),
                  Switch(
                    value: _aktif,
                    onChanged: (val) => setState(() => _aktif = val),
                  ),
                ],
              ),
              const Gap(32),
              PrimaryButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving 
                    ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator()) 
                    : Text(widget.preferensiToEdit != null ? 'Simpan Perubahan' : 'Tambah Pengingat'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
