import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:provider/provider.dart';
import 'package:snap_notes_mvvm/features/pengeluaran/models/pengeluaran.dart';
import 'package:snap_notes_mvvm/features/pengeluaran/viewmodels/pengeluaran_viewmodel.dart';
import 'package:snap_notes_mvvm/features/pengeluaran/models/kategori.dart';
import 'package:snap_notes_mvvm/utils/format_utils.dart';
import 'package:snap_notes_mvvm/utils/rupiah_input_formatter.dart';
import 'package:snap_notes_mvvm/features/receipt/views/pages/full_screen_image_page.dart';
import 'package:snap_notes_mvvm/core/utils/toast_formatter.dart';


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
  final _promptController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String? _selectedCategoryId;

  bool get isEdit => widget.pengeluaran != null;
  bool get isStruk => isEdit && widget.pengeluaran!.strukId != null;

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
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final viewModel = context.read<PengeluaranViewModel>();

    if (isStruk) {
      final prompt = _promptController.text.trim();
      
      // Mengambil nama kategori yang dipilih
      final selectedCategory = viewModel.categories.firstWhere(
        (c) => c.id == _selectedCategoryId,
        orElse: () => Kategori(id: '', nama: 'Lainnya', jenis: 'PENGELUARAN', adalahPreset: true),
      );
      final selectedKategoriNama = selectedCategory.nama;

      if (_selectedCategoryId == null && prompt.isEmpty) {
        showToast(
          context: context,
          builder: (context, overlay) => ToastFormatter.validation('Kategori atau prompt koreksi harus diisi'),
          location: ToastLocation.bottomRight,
        );
        return;
      }

      String promptToSend = '';
      if (_selectedCategoryId != null) {
        promptToSend += 'Kategori transaksi/toko ini harus diklasifikasikan sebagai "$selectedKategoriNama". Harap set kategori toko menjadi "$selectedKategoriNama" dan set kategori item-item yang sesuai menjadi "$selectedKategoriNama". ';
      }
      if (prompt.isNotEmpty) {
        promptToSend += 'Koreksi tambahan: $prompt';
      } else if (_selectedCategoryId != null) {
        promptToSend += 'Tidak ada koreksi teks tambahan.';
      }

      await viewModel.reparseStruk(widget.pengeluaran!.strukId!, promptToSend);

      if (mounted) {
        if (viewModel.errorMessage != null) {
          showToast(
            context: context,
            builder: (context, overlay) => ToastFormatter.error('Gagal', viewModel.errorMessage!),
            location: ToastLocation.bottomRight,
          );
        } else {
          showToast(
            context: context,
            builder: (context, overlay) => ToastFormatter.success('Struk berhasil diproses ulang dengan AI'),
            location: ToastLocation.bottomRight,
          );
          Navigator.pop(context, true);
        }
      }
      return;
    }

    final deskripsi = _deskripsiController.text.trim();
    final jumlahStr = _jumlahController.text.trim();

    if (deskripsi.isEmpty) {
      showToast(
        context: context,
        builder: (context, overlay) => ToastFormatter.validation('Deskripsi tidak boleh kosong'),
        location: ToastLocation.bottomRight,
      );
      return;
    }

    // Mem-parse string nominal terformat kembali ke double secara aman
    final jumlah = FormatUtils.parseRupiahToDouble(jumlahStr);
    if (jumlah <= 0) {
      showToast(
        context: context,
        builder: (context, overlay) => ToastFormatter.validation('Jumlah tidak valid'),
        location: ToastLocation.bottomRight,
      );
      return;
    }

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
          builder: (context, overlay) => ToastFormatter.error('Gagal menyimpan pengeluaran', viewModel.errorMessage!),
          location: ToastLocation.bottomRight,
        );
      } else {
        showToast(
          context: context,
          builder: (context, overlay) => ToastFormatter.success(isEdit ? 'Pengeluaran berhasil diubah' : 'Pengeluaran berhasil disimpan'),
          location: ToastLocation.bottomRight,
        );
        Navigator.pop(context, true);
      }
    }
  }

  Widget _buildCategorySelect(PengeluaranViewModel viewModel) {
    return Select<String>(
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
          orElse: () {
            if (widget.pengeluaran != null && widget.pengeluaran!.kategoriId == itemValue) {
              return Kategori(
                id: itemValue,
                nama: widget.pengeluaran!.kategoriNama ?? 'Lainnya',
                jenis: 'PENGELUARAN',
                adalahPreset: true,
              );
            }
            return Kategori(id: '', nama: 'Lainnya', jenis: 'PENGELUARAN', adalahPreset: true);
          },
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
    );
  }


  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PengeluaranViewModel>();
    final isLoading = viewModel.isLoading;
    final imageUrl = widget.pengeluaran?.struk?.imageUrl;

    return Scaffold(
      headers: [
        AppBar(
          title: Text(isStruk ? 'Edit Struk' : (isEdit ? 'Ubah Pengeluaran' : 'Tambah Pengeluaran')),
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
            children: isStruk
                ? [
                    // Card Data Struk yang sedang di-edit
                    Card(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (imageUrl != null && imageUrl.isNotEmpty) ...[
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FullScreenImagePage(
                                      imageUrl: imageUrl,
                                      title: 'Foto Struk',
                                    ),
                                  ),
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  imageUrl,
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    height: 120,
                                    color: Theme.of(context).colorScheme.muted,
                                    child: Center(
                                      child: Icon(LucideIcons.imageOff, color: Theme.of(context).colorScheme.mutedForeground, size: 36),
                                    ),
                                  ),
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      height: 180,
                                      color: Theme.of(context).colorScheme.muted,
                                      child: const Center(child: CircularProgressIndicator()),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const Gap(16),
                          ],
                          
                          // Informasi Struk
                          Text(widget.pengeluaran?.deskripsi ?? 'Struk Belanja').large().bold(),
                          const Gap(4),
                          Row(
                            children: [
                              Icon(LucideIcons.calendar, size: 14, color: Theme.of(context).colorScheme.mutedForeground),
                              const Gap(6),
                              Text(widget.pengeluaran != null
                                  ? '${widget.pengeluaran!.tanggal.day}/${widget.pengeluaran!.tanggal.month}/${widget.pengeluaran!.tanggal.year}'
                                  : '').small().muted(),
                            ],
                          ),
                          const Gap(16),
                          const Divider(),
                          const Gap(12),
                          const Text('Item Belanja').small().semiBold(),
                          const Gap(8),
                          if (widget.pengeluaran?.struk != null && widget.pengeluaran!.struk!.items.isNotEmpty)
                            ...widget.pengeluaran!.struk!.items.map((item) => Padding(
                              padding: const EdgeInsets.only(bottom: 6.0),
                              child: Row(
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
                                      '${item.quantity} x Rp ${item.price.toStringAsFixed(0)}',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context).typography.small.copyWith(
                                        color: Theme.of(context).colorScheme.mutedForeground,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      'Rp ${item.totalPrice.toStringAsFixed(0)}',
                                      textAlign: TextAlign.right,
                                      style: Theme.of(context).typography.small.copyWith(fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                            ))
                          else
                            const Text('Tidak ada item belanja').italic().muted().small(),
                          const Gap(12),
                          const Divider(),
                          const Gap(12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total').small().semiBold(),
                              Text(widget.pengeluaran != null
                                  ? 'Rp ${widget.pengeluaran!.jumlah.toStringAsFixed(0)}'
                                  : '').small().semiBold(),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Gap(24),
                    
                    const Text('Kategori').medium(),
                    const Gap(8),
                    _buildCategorySelect(viewModel),
                    const Gap(20),


                    
                    const Text('Prompt Koreksi (Opsional)').medium(),
                    const Gap(8),
                    TextField(
                      controller: _promptController,
                      minLines: 3,
                      maxLines: 5,
                      placeholder: const Text('Contoh: Koreksi nama toko menjadi Indomaret, harga barang A salah harusnya 12.000'),
                    ),
                    const Gap(24),

                    SurfaceCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(LucideIcons.sparkles, color: Theme.of(context).colorScheme.primary, size: 18),
                              const Gap(8),
                              const Text('Koreksi dengan AI (Gemini)').semiBold().small(),
                            ],
                          ),
                          const Gap(8),
                          const Text(
                            'Masukkan instruksi koreksi untuk memproses ulang data struk. AI akan membaca instruksi Anda beserta kategori pilihan Anda di atas untuk menyusun kembali detail transaksi.',
                          ).muted().xSmall(),
                        ],
                      ),
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
                                Text('Memproses Ulang...'),
                              ],
                            )
                          : const Text('Simpan Perubahan'),
                    ),
                  ]
                : [
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
                    _buildCategorySelect(viewModel),
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
