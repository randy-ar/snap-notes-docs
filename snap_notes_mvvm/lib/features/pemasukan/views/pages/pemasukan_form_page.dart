import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:provider/provider.dart';
import 'package:snap_notes_mvvm/core/di/injection.dart';
import 'package:snap_notes_mvvm/features/pemasukan/models/pemasukan.dart';
import 'package:snap_notes_mvvm/features/pemasukan/viewmodels/pemasukan_viewmodel.dart';

class PemasukanFormPage extends StatefulWidget {
  final Pemasukan? pemasukan;
  const PemasukanFormPage({super.key, this.pemasukan});

  @override
  State<PemasukanFormPage> createState() => _PemasukanFormPageState();
}

class _PemasukanFormPageState extends State<PemasukanFormPage> {
  final _deskripsiController = TextEditingController();
  final _jumlahController = TextEditingController();
  final _catatanController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  bool get isEdit => widget.pemasukan != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      _deskripsiController.text = widget.pemasukan!.deskripsi;
      _jumlahController.text = widget.pemasukan!.jumlah.toStringAsFixed(0);
      _catatanController.text = widget.pemasukan!.catatan ?? '';
      _selectedDate = widget.pemasukan!.tanggal;
    }
  }

  @override
  void dispose() {
    _deskripsiController.dispose();
    _jumlahController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final deskripsi = _deskripsiController.text.trim();
    final jumlahStr = _jumlahController.text.trim();

    if (deskripsi.isEmpty) {
      _showToast('Error', 'Deskripsi tidak boleh kosong');
      return;
    }

    final jumlah = double.tryParse(jumlahStr);
    if (jumlah == null || jumlah <= 0) {
      _showToast('Error', 'Jumlah tidak valid');
      return;
    }

    final viewModel = context.read<PemasukanViewModel>();

    if (isEdit) {
      await viewModel.updatePemasukan(
        widget.pemasukan!.id,
        deskripsi: deskripsi,
        jumlah: jumlah,
        tanggal: _selectedDate,
        catatan: _catatanController.text.trim().isNotEmpty ? _catatanController.text.trim() : null,
      );
    } else {
      await viewModel.tambahPemasukan(
        deskripsi: deskripsi,
        jumlah: jumlah,
        tanggal: _selectedDate,
        catatan: _catatanController.text.trim().isNotEmpty ? _catatanController.text.trim() : null,
      );
    }

    if (!mounted) return;

    if (viewModel.errorMessage != null) {
      _showToast('Gagal', viewModel.errorMessage!);
    } else {
      _showToast('Berhasil', isEdit ? 'Berhasil mengubah pemasukan' : 'Berhasil menambahkan pemasukan');
      Navigator.pop(context, true);
    }
  }

  void _showToast(String title, String message) {
    showToast(
      context: context,
      builder: (context, overlay) => SurfaceCard(
        child: Basic(title: Text(title), subtitle: Text(message)),
      ),
      location: ToastLocation.bottomRight,
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PemasukanViewModel>();
    
    return Scaffold(
      headers: [
        AppBar(
          title: Text(isEdit ? 'Ubah Pemasukan' : 'Tambah Pemasukan'),
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
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Deskripsi').medium(),
              const Gap(8),
              TextField(
                controller: _deskripsiController,
                placeholder: const Text('Contoh: Gaji bulanan'),
              ),
              const Gap(20),
              
              const Text('Jumlah (Rp)').medium(),
              const Gap(8),
              TextField(
                controller: _jumlahController,
                keyboardType: TextInputType.number,
                placeholder: const Text('Contoh: 5000000'),
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
                onPressed: viewModel.isLoading ? null : _submit,
                child: viewModel.isLoading
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
                    : Text(isEdit ? 'Simpan Perubahan' : 'Simpan Pemasukan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Helper untuk navigate ke form pemasukan
void navigateToPemasukanForm(BuildContext context, {Pemasukan? pemasukan}) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => ChangeNotifierProvider(
        create: (_) => getIt<PemasukanViewModel>(),
        child: PemasukanFormPage(pemasukan: pemasukan),
      ),
    ),
  );
}

