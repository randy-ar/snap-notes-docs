import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:provider/provider.dart';
import 'package:snap_notes_mvvm/features/pengeluaran/models/pengeluaran.dart';
import 'package:snap_notes_mvvm/features/pengeluaran/viewmodels/pengeluaran_viewmodel.dart';
import 'package:snap_notes_mvvm/features/pengeluaran/models/kategori.dart';
import 'package:snap_notes_mvvm/utils/format_utils.dart';
import 'package:snap_notes_mvvm/utils/rupiah_input_formatter.dart';

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
  String? _selectedCategoryId;

  bool get isEdit => widget.pengeluaran != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      _deskripsiController.text = widget.pengeluaran!.deskripsi;
      // Memformat nominal awal dengan separator ribuan (misal: 25.000)
      _jumlahController.text = FormatUtils.formatRupiah(widget.pengeluaran!.jumlah).replaceAll('Rp ', '');
      _catatanController.text = widget.pengeluaran!.catatan ?? '';
      _selectedDate = widget.pengeluaran!.tanggal;
      _selectedCategoryId = widget.pengeluaran!.kategoriId;
    }

    // Muat daftar kategori dari backend
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PengeluaranViewModel>().loadCategories(jenis: 'PENGELUARAN');
    });
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
      showToast(
        context: context,
        builder: (context, overlay) => const SurfaceCard(
          child: Basic(title: Text('Error'), subtitle: Text('Deskripsi tidak boleh kosong')),
        ),
        location: ToastLocation.bottomRight,
      );
      return;
    }

    // Mem-parse string nominal terformat kembali ke double secara aman
    final jumlah = FormatUtils.parseRupiahToDouble(jumlahStr);
    if (jumlah <= 0) {
      showToast(
        context: context,
        builder: (context, overlay) => const SurfaceCard(
          child: Basic(title: Text('Error'), subtitle: Text('Jumlah tidak valid')),
        ),
        location: ToastLocation.bottomRight,
      );
      return;
    }

    final viewModel = context.read<PengeluaranViewModel>();

    if (isEdit) {
      await viewModel.updatePengeluaran(
        widget.pengeluaran!.id,
        deskripsi: deskripsi,
        jumlah: jumlah,
        tanggal: _selectedDate,
        kategoriId: _selectedCategoryId,
        catatan: _catatanController.text.trim().isNotEmpty ? _catatanController.text.trim() : null,
      );
    } else {
      await viewModel.tambahPengeluaran(
        deskripsi: deskripsi,
        jumlah: jumlah,
        tanggal: _selectedDate,
        kategoriId: _selectedCategoryId,
        catatan: _catatanController.text.trim().isNotEmpty ? _catatanController.text.trim() : null,
      );
    }

    if (mounted) {
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
          builder: (context, overlay) => SurfaceCard(
            child: Basic(
              title: const Text('Berhasil'),
              subtitle: Text(isEdit ? 'Berhasil mengubah pengeluaran' : 'Berhasil menambahkan pengeluaran'),
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
    final isLoading = viewModel.isLoading;

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
                placeholder: const Text('Contoh: Makan Siang'),
              ),
              const Gap(20),
              
              const Text('Jumlah (Rp)').medium(),
              const Gap(8),
              TextField(
                controller: _jumlahController,
                keyboardType: TextInputType.number,
                placeholder: const Text('Contoh: 25.000'),
                inputFormatters: [RupiahInputFormatter()],
                features: const [
                  InputFeature.leading(Text('Rp ')),
                ],
              ),
              const Gap(20),

              const Text('Kategori').medium(),
              const Gap(8),
              Select<String>(
                value: _selectedCategoryId,
                placeholder: const Text('Pilih Kategori'),
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryId = value;
                  });
                },
                itemBuilder: (context, itemValue) {
                  final category = viewModel.categories.firstWhere(
                    (c) => c.id == itemValue,
                    orElse: () => Kategori(id: '', nama: 'Lainnya', jenis: 'PENGELUARAN', adalahPreset: true),
                  );
                  return Text(category.nama);
                },
                popup: SelectPopup<String>.builder(
                  searchPlaceholder: const Text('Cari kategori...'),
                  builder: (context, searchQuery) {
                    final filtered = searchQuery == null
                        ? viewModel.categories
                        : viewModel.categories
                            .where((c) => c.nama.toLowerCase().contains(searchQuery.toLowerCase()))
                            .toList();
                    return SelectItemList(
                      children: [
                        for (final category in filtered)
                          SelectItemButton(
                            value: category.id,
                            child: Text(category.nama),
                          ),
                      ],
                    );
                  },
                ),
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
      ),
    );
  }
}
