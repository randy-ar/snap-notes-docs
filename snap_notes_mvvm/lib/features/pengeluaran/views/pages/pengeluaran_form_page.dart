import 'dart:io';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snap_notes_mvvm/features/pengeluaran/models/pengeluaran.dart';
import 'package:snap_notes_mvvm/features/pengeluaran/viewmodels/pengeluaran_viewmodel.dart';
import 'package:snap_notes_mvvm/features/pengeluaran/models/kategori.dart';
import 'package:snap_notes_mvvm/utils/format_utils.dart';
import 'package:snap_notes_mvvm/utils/rupiah_input_formatter.dart';
import 'package:snap_notes_mvvm/features/receipt/views/pages/full_screen_image_page.dart';
import 'package:snap_notes_mvvm/core/utils/toast_formatter.dart';
import 'package:snap_notes_mvvm/features/receipt/models/receipt.dart';

class _ItemEditGroup {
  final String? id;
  final TextEditingController nameController;
  final TextEditingController quantityController;
  final TextEditingController priceController;
  final TextEditingController discountController;
  final TextEditingController totalPriceController;
  String? categoryId;
  String? categoryName;

  _ItemEditGroup({
    this.id,
    required this.nameController,
    required this.quantityController,
    required this.priceController,
    required this.discountController,
    required this.totalPriceController,
    this.categoryId,
    this.categoryName,
  });

  factory _ItemEditGroup.fromItem(ReceiptItem item) {
    // Pada item edit group yang merupakan mode struk, hitung/sertakan discount-nya.
    return _ItemEditGroup(
      id: item.id,
      nameController: TextEditingController(text: item.name),
      quantityController: TextEditingController(text: item.quantity.toString()),
      priceController: TextEditingController(text: FormatUtils.formatDecimalRibuan(item.price)),
      discountController: TextEditingController(
        text: item.discount != null && item.discount! > 0
            ? FormatUtils.formatDecimalRibuan(item.discount)
            : '',
      ),
      totalPriceController: TextEditingController(text: FormatUtils.formatDecimalRibuan(item.totalPrice)),
      categoryId: item.categoryId,
      categoryName: item.categoryName,
    );
  }

  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    priceController.dispose();
    discountController.dispose();
    totalPriceController.dispose();
  }
}

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
  late List<_ItemEditGroup> _itemGroups;

  bool get isEdit => widget.pengeluaran != null;
  bool get isStruk => (isEdit && widget.pengeluaran!.strukId != null) || !isEdit;

  // Variabel untuk menyimpan gambar struk manual
  File? _strukImageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _strukImageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        showToast(
          context: context,
          builder: (context, overlay) => ToastFormatter.error('Gagal', 'Tidak dapat memuat gambar: $e'),
          location: ToastLocation.bottomRight,
        );
      }
    }
  }

  void _removeImage() {
    setState(() {
      _strukImageFile = null;
    });
  }
  void initState() {
    super.initState();
    if (isEdit) {
      _deskripsiController.text = widget.pengeluaran!.deskripsi;
      // Memformat nominal awal dengan separator ribuan (misal: 25.000)
      _jumlahController.text = FormatUtils.formatDecimalRibuan(widget.pengeluaran!.jumlah);
      _catatanController.text = widget.pengeluaran!.catatan ?? '';
      _selectedDate = widget.pengeluaran!.tanggal;
      _selectedCategoryId = widget.pengeluaran!.kategoriId;
    }

    if (isStruk) {
      if (isEdit) {
        _itemGroups = widget.pengeluaran!.struk!.items.map((item) => _ItemEditGroup.fromItem(item)).toList();
      } else {
        _itemGroups = [
          _ItemEditGroup(
            nameController: TextEditingController(),
            quantityController: TextEditingController(text: '1'),
            priceController: TextEditingController(text: ''),
            discountController: TextEditingController(text: ''),
            totalPriceController: TextEditingController(text: ''),
          )
        ];
      }
    } else {
      _itemGroups = [];
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
    for (final group in _itemGroups) {
      group.dispose();
    }
    super.dispose();
  }

  void _recalculateItemTotal(_ItemEditGroup group) {
    final qty = int.tryParse(group.quantityController.text) ?? 0;
    final price = FormatUtils.parseRupiahToDouble(group.priceController.text);
    final discount = FormatUtils.parseRupiahToDouble(group.discountController.text);
    final total = (qty * price) - discount;
    group.totalPriceController.text = FormatUtils.formatDecimalRibuan(total);
    _recalculateGrandTotal();
  }

  void _recalculateGrandTotal() {
    double total = 0;
    for (final group in _itemGroups) {
      total += FormatUtils.parseRupiahToDouble(group.totalPriceController.text);
    }
    _jumlahController.text = FormatUtils.formatDecimalRibuan(total);
  }

  void _addItem() {
    setState(() {
      _itemGroups.add(
        _ItemEditGroup(
          nameController: TextEditingController(),
          quantityController: TextEditingController(text: '1'),
          priceController: TextEditingController(text: ''),
          discountController: TextEditingController(text: ''),
          totalPriceController: TextEditingController(text: ''),
        ),
      );
    });
  }

  void _removeItem(int index) {
    setState(() {
      _itemGroups[index].dispose();
      _itemGroups.removeAt(index);
      _recalculateGrandTotal();
    });
  }

  Future<void> _submit() async {
    final viewModel = context.read<PengeluaranViewModel>();

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
      List<ReceiptItem>? strukItems;
      if (isStruk) {
        strukItems = _itemGroups.map((group) {
          final qty = int.tryParse(group.quantityController.text) ?? 1;
          final price = FormatUtils.parseRupiahToDouble(group.priceController.text);
          final discount = FormatUtils.parseRupiahToDouble(group.discountController.text);
          final total = FormatUtils.parseRupiahToDouble(group.totalPriceController.text);
          return ReceiptItem(
            name: group.nameController.text.trim().isEmpty ? 'Item Belanja' : group.nameController.text.trim(),
            quantity: qty,
            price: price,
            discount: discount > 0 ? discount : null,
            totalPrice: total,
            categoryId: group.categoryId,
            categoryName: group.categoryName,
          );
        }).toList();
      }

      await viewModel.updatePengeluaran(
        widget.pengeluaran!.id,
        deskripsi: deskripsi,
        jumlah: jumlah,
        tanggal: _selectedDate,
        kategoriId: _selectedCategoryId,
        catatan: _catatanController.text.trim().isNotEmpty ? _catatanController.text.trim() : null,
        strukId: widget.pengeluaran!.strukId,
        strukItems: strukItems,
      );
    } else {
      List<ReceiptItem>? strukItems;
      if (isStruk) {
         strukItems = _itemGroups.map((group) {
          final qty = int.tryParse(group.quantityController.text) ?? 1;
          final price = FormatUtils.parseRupiahToDouble(group.priceController.text);
          final discount = FormatUtils.parseRupiahToDouble(group.discountController.text);
          final total = FormatUtils.parseRupiahToDouble(group.totalPriceController.text);
          return ReceiptItem(
            name: group.nameController.text.trim().isEmpty ? 'Item Belanja' : group.nameController.text.trim(),
            quantity: qty,
            price: price,
            discount: discount > 0 ? discount : null,
            totalPrice: total,
            categoryId: group.categoryId,
            categoryName: group.categoryName,
          );
        }).toList();
      }

      await viewModel.tambahPengeluaran(
        deskripsi: deskripsi,
        jumlah: jumlah,
        tanggal: _selectedDate,
        kategoriId: _selectedCategoryId,
        catatan: _catatanController.text.trim().isNotEmpty ? _catatanController.text.trim() : null,
        strukItems: strukItems,
        imagePath: _strukImageFile?.path,
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
          title: Text(isStruk ? 'Simpan Struk' : (isEdit ? 'Ubah Pengeluaran' : 'Tambah Pengeluaran')),
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
                    Column(
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
                          ] else if (_strukImageFile != null) ...[
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    _strukImageFile!,
                                    height: 180,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: IconButton.ghost(
                                    icon: const Icon(LucideIcons.x, size: 16),
                                    onPressed: _removeImage,
                                  ),
                                ),
                              ],
                            ),
                            const Gap(16),
                          ] else if (!isEdit) ...[
                            GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                height: 120,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Theme.of(context).colorScheme.border,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  color: Theme.of(context).colorScheme.muted.withValues(alpha: 0.5),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      LucideIcons.camera,
                                      color: Theme.of(context).colorScheme.mutedForeground,
                                      size: 32,
                                    ),
                                    const Gap(8),
                                    Text(
                                      'Upload Foto Struk (Opsional)',
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.mutedForeground,
                                      ),
                                    ).small(),
                                  ],
                                ),
                              ),
                            ),
                            const Gap(16),
                          ],
                          const Text('Informasi Umum').large().bold(),
                          const Gap(16),
                          const Text('Nama Toko').small().semiBold(),
                          const Gap(4),
                          TextField(
                            controller: _deskripsiController,
                            placeholder: const Text('Masukkan nama toko'),
                          ),
                          const Gap(16),
                          const Text('Tanggal Pembelian').small().semiBold(),
                          const Gap(4),
                          DatePicker(
                            value: _selectedDate,
                            onChanged: (date) {
                              if (date != null) {
                                setState(() {
                                  _selectedDate = date;
                                });
                              }
                            },
                          ),
                          const Gap(16),
                          const Text('Kategori').small().semiBold(),
                          const Gap(4),
                          _buildCategorySelect(viewModel),
                          const Gap(16),
                          const Text('Total Harga (Rp)').small().semiBold(),
                          const Gap(4),
                          TextField(
                            controller: _jumlahController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [RupiahInputFormatter()],
                            placeholder: const Text('0'),
                            readOnly: true,
                          ),
                          const Gap(16),
                          const Text('Catatan (Opsional)').small().semiBold(),
                          const Gap(4),
                          TextField(
                            controller: _catatanController,
                            maxLines: 2,
                            placeholder: const Text('Tambahkan catatan'),
                          ),
                          const Gap(16),
                          const Divider(),
                          const Gap(12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Item Belanja').small().semiBold(),
                              IconButton.ghost(
                                size: ButtonSize.small,
                                icon: const Icon(LucideIcons.plus, size: 16),
                                onPressed: _addItem,
                              ),
                            ],
                          ),
                          const Gap(8),
                          if (_itemGroups.isNotEmpty)
                            ..._itemGroups.asMap().entries.map((entry) {
                              final index = entry.key;
                              final group = entry.value;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Card(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Item #${index + 1}').small().semiBold(),
                                          IconButton.ghost(
                                            size: ButtonSize.small,
                                            icon: Icon(
                                              LucideIcons.trash2,
                                              size: 16,
                                              color: Theme.of(context).colorScheme.destructive,
                                            ),
                                            onPressed: () => _removeItem(index),
                                          ),
                                        ],
                                      ),
                                      const Gap(8),
                                      const Text('Nama Item').xSmall().muted(),
                                      const Gap(4),
                                      TextField(
                                        controller: group.nameController,
                                        placeholder: const Text('Nama produk'),
                                      ),
                                      const Gap(8),
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text('Jumlah').xSmall().muted(),
                                                const Gap(4),
                                                TextField(
                                                  controller: group.quantityController,
                                                  keyboardType: TextInputType.number,
                                                  onChanged: (_) => _recalculateItemTotal(group),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Gap(12),
                                          Expanded(
                                            flex: 3,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text('Harga Satuan').xSmall().muted(),
                                                const Gap(4),
                                                TextField(
                                                  controller: group.priceController,
                                                  keyboardType: TextInputType.number,
                                                  inputFormatters: [RupiahInputFormatter()],
                                                  onChanged: (_) => _recalculateItemTotal(group),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Gap(8),
                                      const Text('Diskon Item (Rp)').xSmall().muted(),
                                      const Gap(4),
                                      TextField(
                                        controller: group.discountController,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [RupiahInputFormatter()],
                                        onChanged: (_) => _recalculateItemTotal(group),
                                        placeholder: const Text('Opsional'),
                                      ),
                                      const Gap(8),
                                      const Text('Subtotal / Total Harga Item (Rp)').xSmall().muted(),
                                      const Gap(4),
                                      TextField(
                                        controller: group.totalPriceController,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [RupiahInputFormatter()],
                                        onChanged: (_) => _recalculateGrandTotal(),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            })
                          else
                            const Text('Tidak ada item belanja').italic().muted().small(),
                          const Gap(12),
                          const Divider(),
                          const Gap(12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total').small().semiBold(),
                              Text('Rp ${_jumlahController.text}').small().semiBold(),
                            ],
                          ),
                        ],
                      ),
                    const Gap(24),

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
