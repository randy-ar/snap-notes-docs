import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snap_notes/features/pengeluaran/domain/entities/pengeluaran.dart';
import 'package:snap_notes/features/pengeluaran/presentation/cubit/pengeluaran_form_cubit.dart';
import 'package:snap_notes/features/pengeluaran/presentation/cubit/pengeluaran_form_state.dart';

class PengeluaranFormPage extends StatefulWidget {
  final Pengeluaran? pengeluaran;
  const PengeluaranFormPage({super.key, this.pengeluaran});

  @override
  State<PengeluaranFormPage> createState() => _PengeluaranFormPageState();
}

class _PengeluaranFormPageState extends State<PengeluaranFormPage> {
  final _deskripsiController = TextEditingController();
  final _jumlahController = TextEditingController();
  final _catatanController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  bool get isEdit => widget.pengeluaran != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      _deskripsiController.text = widget.pengeluaran!.deskripsi;
      _jumlahController.text = widget.pengeluaran!.jumlah.toStringAsFixed(0);
      _catatanController.text = widget.pengeluaran!.catatan ?? '';
      _selectedDate = widget.pengeluaran!.tanggal;
    }
  }

  @override
  void dispose() {
    _deskripsiController.dispose();
    _jumlahController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  void _submit() {
    final deskripsi = _deskripsiController.text.trim();
    final jumlahStr = _jumlahController.text.trim();

    if (deskripsi.isEmpty) {
      showToast(
        context: context,
        builder: (context, overlay) => SurfaceCard(
          child: Basic(title: const Text('Error'), subtitle: const Text('Deskripsi tidak boleh kosong')),
        ),
        location: ToastLocation.bottomRight,
      );
      return;
    }

    final jumlah = double.tryParse(jumlahStr);
    if (jumlah == null || jumlah <= 0) {
      showToast(
        context: context,
        builder: (context, overlay) => SurfaceCard(
          child: Basic(title: const Text('Error'), subtitle: const Text('Jumlah tidak valid')),
        ),
        location: ToastLocation.bottomRight,
      );
      return;
    }

    context.read<PengeluaranFormCubit>().simpanPengeluaran(
          id: widget.pengeluaran?.id,
          deskripsi: deskripsi,
          jumlah: jumlah,
          tanggal: _selectedDate,
          catatan: _catatanController.text.trim().isNotEmpty ? _catatanController.text.trim() : null,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      headers: [
        AppBar(
          title: Text(isEdit ? 'Ubah Pengeluaran' : 'Tambah Pengeluaran'),
          leading: [
            IconButton.ghost(
              icon: const Icon(LucideIcons.arrowLeft),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ],
      child: BlocConsumer<PengeluaranFormCubit, PengeluaranFormState>(
        listener: (context, state) {
          if (state is PengeluaranFormSuccess) {
            showToast(
              context: context,
              builder: (context, overlay) => SurfaceCard(
                child: Basic(
                  title: const Text('Berhasil'),
                  subtitle: Text(isEdit ? 'Berhasil mengubah pengeluaran' : 'Berhasil menambahkan pengeluaran'),
                ),
              ),
              location: ToastLocation.bottomRight,
            );
            Navigator.pop(context, true);
          } else if (state is PengeluaranFormError) {
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
          final isLoading = state is PengeluaranFormLoading;
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Deskripsi').medium(),
                  const Gap(8),
                  TextField(
                    controller: _deskripsiController,
                    placeholder: const Text('Contoh: Makan Siang'),
                  ),
                  const Gap(20),
                  
                  const Text('Jumlah (Rp)').medium(),
                  const Gap(8),
                  TextField(
                    controller: _jumlahController,
                    keyboardType: TextInputType.number,
                    placeholder: const Text('Contoh: 25000'),
                    features: const [
                      InputFeature.leading(Text('Rp ')),
                    ],
                  ),
                  const Gap(20),

                  const Text('Tanggal').medium(),
                  const Gap(8),
                  DatePicker(
                    value: _selectedDate,
                    mode: PromptMode.popover,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedDate = value;
                        });
                      }
                    },
                  ),
                  const Gap(20),

                  const Text('Catatan (Opsional)').medium(),
                  const Gap(8),
                  TextField(
                    controller: _catatanController,
                    minLines: 3,
                    maxLines: 5,
                    placeholder: const Text('Tambahkan catatan jika perlu'),
                  ),
                  const Gap(40),

                  PrimaryButton(
                    onPressed: isLoading ? null : _submit,
                    child: isLoading
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(),
                              ),
                              Gap(8),
                              Text('Menyimpan...'),
                            ],
                          )
                        : Text(isEdit ? 'Simpan Perubahan' : 'Simpan Pengeluaran'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
