import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:provider/provider.dart';
import 'package:snap_notes_mvvm/core/di/injection.dart';
import 'package:snap_notes_mvvm/core/utils/toast_formatter.dart';
import 'package:snap_notes_mvvm/features/pemasukan/models/pemasukan.dart';
import 'package:snap_notes_mvvm/features/pemasukan/viewmodels/pemasukan_viewmodel.dart';
import 'package:snap_notes_mvvm/features/pengeluaran/models/kategori.dart';
import 'package:snap_notes_mvvm/utils/format_utils.dart';
import 'package:snap_notes_mvvm/utils/rupiah_input_formatter.dart';

class PemasukanFormPage extends StatefulWidget {
  final Pemasukan? pemasukan;
  const PemasukanFormPage({super.key, this.pemasukan});

  @override
  State<PemasukanFormPage> createState() => _PemasukanFormPageState();
}

class _PemasukanFormPageState extends State<PemasukanFormPage> {
  final _deskripsiKey = const TextFieldKey('deskripsi');
  final _jumlahKey = const TextFieldKey('jumlah');
  final _kategoriKey = const SelectKey<String>('kategori');
  final _tanggalKey = const DatePickerKey('tanggal');
  final _catatanKey = const TextFieldKey('catatan');

  final _deskripsiController = TextEditingController();
  final _jumlahController = TextEditingController();
  final _catatanController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String? _selectedCategoryId;

  bool get isEdit => widget.pemasukan != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      _deskripsiController.text = widget.pemasukan!.deskripsi;
      _jumlahController.text = FormatUtils.formatRupiah(widget.pemasukan!.jumlah).replaceAll('Rp ', '');
      _catatanController.text = widget.pemasukan!.catatan ?? '';
      _selectedDate = widget.pemasukan!.tanggal;
      _selectedCategoryId = widget.pemasukan!.kategoriId;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PemasukanViewModel>().loadCategories(jenis: 'PEMASUKAN');
    });
  }

  @override
  void dispose() {
    _deskripsiController.dispose();
    _jumlahController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _submit(Map<FormKey<dynamic>, dynamic> values) async {
    final deskripsi = _deskripsiKey[values] ?? _deskripsiController.text.trim();
    final jumlahStr = _jumlahKey[values] ?? _jumlahController.text.trim();
    final tanggal = _tanggalKey[values] ?? _selectedDate;
    final categoryId = _kategoriKey[values] ?? _selectedCategoryId;
    final catatan = _catatanKey[values] ?? _catatanController.text.trim();

    final jumlah = FormatUtils.parseRupiahToDouble(jumlahStr);
    final viewModel = context.read<PemasukanViewModel>();

    await viewModel.submitPemasukan(
      id: isEdit ? widget.pemasukan!.id : null,
      deskripsi: deskripsi,
      jumlah: jumlah,
      tanggal: tanggal,
      kategoriId: categoryId,
      catatan: catatan.isNotEmpty ? catatan : null,
    );

    if (!mounted) return;

    if (viewModel.errorMessage != null) {
      _showToastError('Gagal menyimpan pemasukan', viewModel.errorMessage!);
    } else {
      _showToastSuccess(isEdit ? 'Pemasukan berhasil diubah' : 'Pemasukan berhasil disimpan');
      Navigator.pop(context, true);
    }
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
          child: Form(
            onSubmit: (context, values) async {
              await _submit(values);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FormField<String>(
                  key: _deskripsiKey,
                  label: const Text('Deskripsi').medium(),
                  showErrors: const {FormValidationMode.changed, FormValidationMode.submitted},
                  validator: const NotEmptyValidator(message: 'Deskripsi tidak boleh kosong') &
                      ValidationMode(
                        ConditionalValidator((value) async {
                          if (value == null || value.trim().isEmpty) return false;
                          return true;
                        }, message: 'Deskripsi wajib diisi'),
                        mode: {FormValidationMode.submitted},
                      ),
                  child: TextField(
                    controller: _deskripsiController,
                    placeholder: const Text('Contoh: Gaji bulanan'),
                  ),
                ),
                const Gap(20),
                FormField<String>(
                  key: _jumlahKey,
                  label: const Text('Jumlah (Rp)').medium(),
                  showErrors: const {FormValidationMode.changed, FormValidationMode.submitted},
                  validator: const NotEmptyValidator(message: 'Jumlah wajib diisi') &
                      ValidationMode(
                        ConditionalValidator((value) async {
                          if (value == null) return false;
                          final doubleVal = FormatUtils.parseRupiahToDouble(value);
                          return doubleVal > 0;
                        }, message: 'Jumlah harus lebih besar dari 0'),
                        mode: {FormValidationMode.submitted},
                      ),
                  child: TextField(
                    controller: _jumlahController,
                    keyboardType: TextInputType.number,
                    placeholder: const Text('Contoh: 5.000.000'),
                    inputFormatters: [RupiahInputFormatter()],
                    features: const [
                      InputFeature.leading(Text('Rp ')),
                    ],
                  ),
                ),
                const Gap(20),
                FormField<String>(
                  key: _kategoriKey,
                  label: const Text('Kategori').medium(),
                  showErrors: const {FormValidationMode.changed, FormValidationMode.submitted},
                  child: Select<String>(
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
                        orElse: () => Kategori(id: '', nama: 'Lainnya', jenis: 'PEMASUKAN', adalahPreset: true),
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
                ),
                const Gap(20),
                FormField<DateTime>(
                  key: _tanggalKey,
                  label: const Text('Tanggal').medium(),
                  showErrors: const {FormValidationMode.changed, FormValidationMode.submitted},
                  validator: const NonNullValidator(message: 'Tanggal wajib diisi'),
                  child: DatePicker(
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
                ),
                const Gap(20),
                FormField<String>(
                  key: _catatanKey,
                  label: const Text('Catatan (Opsional)').medium(),
                  showErrors: const {FormValidationMode.changed, FormValidationMode.submitted},
                  child: TextField(
                    controller: _catatanController,
                    minLines: 3,
                    maxLines: 5,
                    placeholder: const Text('Tambahkan catatan jika perlu'),
                  ),
                ),
                const Gap(40),
                FormErrorBuilder(
                  builder: (context, errors, child) {
                    return PrimaryButton(
                      onPressed: (errors.isEmpty && !viewModel.isLoading)
                          ? () => context.submitForm()
                          : null,
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
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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
