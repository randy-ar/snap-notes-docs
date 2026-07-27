import 'dart:io';
import 'package:flutter/material.dart' show Icons;
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:snap_notes_mvvm/features/receipt/models/receipt.dart';
import 'package:snap_notes_mvvm/features/receipt/viewmodels/receipt_viewmodel.dart';
import 'package:snap_notes_mvvm/features/receipt/views/pages/full_screen_image_page.dart';
import 'package:snap_notes_mvvm/features/receipt/views/widgets/scan_animation_overlay.dart';
import 'package:snap_notes_mvvm/features/pengeluaran/models/kategori.dart';

class ReceiptParsedPage extends StatefulWidget {
  /// Single-mode image
  final File? image;

  /// Batch-mode images
  final List<File>? images;

  /// Single-mode receipt
  final Receipt? receipt;

  /// Batch-mode receipts
  final List<Receipt>? receipts;

  /// Determines layout: single vs batch
  final bool isBatchMode;

  final bool useScaffold;

  const ReceiptParsedPage({
    super.key,
    this.image,
    this.images,
    this.receipt,
    this.receipts,
    required this.isBatchMode,
    this.useScaffold = true,
  });

  @override
  State<ReceiptParsedPage> createState() => _ReceiptParsedPageState();
}

class _ReceiptParsedPageState extends State<ReceiptParsedPage> {
  int _tabIndex = 0;
  int _selectedReceiptIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReceiptViewModel>().loadCategories();
    });
  }

  // ---------------------------------------------------------------------------
  // Public methods (per class diagram)
  // ---------------------------------------------------------------------------

  /// Opens bottom drawer for manual editing / review of receipt data & items (SKPL-008).
  void showKoreksiDrawer() {
    final viewModel = context.read<ReceiptViewModel>();
    final targetReceipt = widget.isBatchMode
        ? (viewModel.batchReceipts.isNotEmpty
            ? viewModel.batchReceipts[_selectedReceiptIndex]
            : widget.receipts![_selectedReceiptIndex])
        : (viewModel.receiptDetail ?? widget.receipt!);
    _openManualEditSheet(
      context,
      viewModel,
      targetReceipt,
      widget.isBatchMode ? _selectedReceiptIndex : null,
    );
  }

  /// Calls viewModel.confirmReceipt()
  void konfirmasiSimpan() {
    context.read<ReceiptViewModel>().confirmReceipt();
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ReceiptViewModel>();

    final mainContent = widget.isBatchMode
        ? _buildBatchContent(context, viewModel)
        : _buildSingleContent(context, viewModel);

    return Stack(
      children: [
        if (widget.useScaffold)
          Scaffold(
            headers: [
              AppBar(
                title: Text(widget.isBatchMode
                    ? 'Hasil Parsing Batch AI'
                    : 'Review Hasil Scan'),
                leading: [
                  IconButton.ghost(
                    onPressed: () => viewModel.cancelScan(),
                    icon: const Icon(LucideIcons.arrowLeft),
                  ),
                ],
              ),
            ],
            child: mainContent,
          )
        else
          mainContent,
        if (viewModel.isLoading)
          const Positioned.fill(
            child: ScanAnimationOverlay(
              text: 'Memproses ulang dengan konteks AI...',
            ),
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Single-mode content (reuses ResponsePreviewPage logic)
  // ---------------------------------------------------------------------------

  Widget _buildSingleContent(BuildContext context, ReceiptViewModel viewModel) {
    final receipt = viewModel.receiptDetail ?? widget.receipt!;
    final image = widget.image!;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSuccessBanner(context),
                const Gap(16),
                Tabs(
                  index: _tabIndex,
                  children: const [
                    TabItem(child: Text('Gambar Struk')),
                    TabItem(child: Text('Data Ekstraksi')),
                  ],
                  onChanged: (int value) {
                    setState(() {
                      _tabIndex = value;
                    });
                  },
                ),
                const Gap(16),
                IndexedStack(
                  index: _tabIndex,
                  children: [
                    // Tab 0: Gambar Struk
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FullScreenImagePage(
                              imageFile: image,
                              title: 'Foto Struk',
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.muted,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Hero(
                            tag: image.path,
                            child: Image.file(
                              image,
                              width: double.infinity,
                              fit: BoxFit.fitWidth,
                              alignment: Alignment.center,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Tab 1: Data Struk
                    _buildParsedReceipt(context, receipt),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Action Buttons — single mode
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Builder(
                  builder: (context) {
                    return SecondaryButton(
                      onPressed: viewModel.isLoading
                          ? null
                          : () => showKoreksiDrawer(),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.pencil, size: 16),
                          Gap(8),
                          Text('Ubah Data'),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const Gap(16),
              Expanded(
                child: PrimaryButton(
                  onPressed:
                      viewModel.isLoading ? null : () => konfirmasiSimpan(),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.check),
                      Gap(8),
                      Text('Simpan Data'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Batch-mode content (reuses BatchResponsePreviewPage logic)
  // ---------------------------------------------------------------------------

  Widget _buildBatchContent(BuildContext context, ReceiptViewModel viewModel) {
    final receipts = viewModel.batchReceipts.isNotEmpty
        ? viewModel.batchReceipts
        : widget.receipts!;
    final images = widget.images!;

    final currentReceipt = receipts.length > _selectedReceiptIndex
        ? receipts[_selectedReceiptIndex]
        : null;
    final currentImg = images.length > _selectedReceiptIndex
        ? images[_selectedReceiptIndex]
        : (images.isNotEmpty ? images.first : null);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
          child: _buildSuccessBanner(context),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Struk ${_selectedReceiptIndex + 1} dari ${receipts.length}')
                  .medium()
                  .semiBold(),
              Row(
                children: [
                  OutlineButton(
                    onPressed: _selectedReceiptIndex > 0
                        ? () => setState(() => _selectedReceiptIndex--)
                        : null,
                    size: ButtonSize.small,
                    child: const Icon(LucideIcons.chevronLeft, size: 16),
                  ),
                  const Gap(8),
                  OutlineButton(
                    onPressed: _selectedReceiptIndex < receipts.length - 1
                        ? () => setState(() => _selectedReceiptIndex++)
                        : null,
                    size: ButtonSize.small,
                    child: const Icon(LucideIcons.chevronRight, size: 16),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Tabs(
            index: _tabIndex,
            children: const [
              TabItem(child: Text('Data Struk Terpilih')),
              TabItem(child: Text('Gambar Struk')),
            ],
            onChanged: (int value) {
              setState(() {
                _tabIndex = value;
              });
            },
          ),
        ),
        const Gap(12),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: IndexedStack(
              index: _tabIndex,
              children: [
                // Tab 0: Data Struk Terpilih
                if (currentReceipt != null)
                  _buildParsedReceipt(context, currentReceipt),

                // Tab 1: Gambar Struk
                if (currentImg != null)
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullScreenImagePage(
                            imageFile: currentImg,
                            title:
                                'Foto Struk ${_selectedReceiptIndex + 1}',
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.muted,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          currentImg,
                          width: double.infinity,
                          fit: BoxFit.fitWidth,
                          alignment: Alignment.center,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Action Button — batch mode
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  onPressed: viewModel.isLoading || currentReceipt == null
                      ? null
                      : () => showKoreksiDrawer(),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.pencil, size: 16),
                      Gap(8),
                      Text('Ubah Data'),
                    ],
                  ),
                ),
              ),
              const Gap(16),
              Expanded(
                child: PrimaryButton(
                  onPressed:
                      viewModel.isLoading ? null : () => konfirmasiSimpan(),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.check, size: 16),
                      Gap(8),
                      Text('Simpan Semua'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Manual edit bottom sheet (SKPL-008: Tinjau Hasil Ekstraksi Struk Belanja)
  // ---------------------------------------------------------------------------

  void _openManualEditSheet(
    BuildContext context,
    ReceiptViewModel viewModel,
    Receipt initialReceipt,
    int? batchIndex,
  ) {
    openDrawer(
      context: context,
      position: OverlayPosition.bottom,
      builder: (drawerContext) {
        return _ManualEditSheet(
          initialReceipt: initialReceipt,
          categories: viewModel.categories,
          onSave: (updatedReceipt) {
            viewModel.updateReceiptManual(updatedReceipt, batchIndex: batchIndex);
          },
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Shared widgets
  // ---------------------------------------------------------------------------

  Widget _buildSuccessBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .primary
            .withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .primary
              .withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle,
              color: Theme.of(context).colorScheme.primary, size: 32),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ekstraksi Berhasil!',
                  style: Theme.of(context).typography.base.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                const Text('AI berhasil menguraikan data struk belanja Anda.')
                    .xSmall()
                    .muted(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParsedReceipt(BuildContext context, Receipt receipt) {
    return Card(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Data Struk:').small().semiBold(),
          const Gap(12),
          _buildDataRow('Nama Toko', receipt.storeName),
          _buildDataRow('Kategori', receipt.categoryName ?? 'Lainnya'),
          _buildDataRow('Tanggal', receipt.date),
          _buildDataRow(
              'Total', 'Rp ${receipt.totalAmount.toStringAsFixed(0)}'),
          const Gap(16),
          const Divider(),
          const Gap(16),
          const Text('Item Belanja:').small().semiBold(),
          const Gap(12),
          ...receipt.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name).small().semiBold(),
                  const Gap(4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${item.quantity} x Rp ${item.price.toStringAsFixed(0)}')
                          .xSmall()
                          .muted(),
                      Text('Rp ${item.totalPrice.toStringAsFixed(0)}')
                          .small()
                          .semiBold(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label).xSmall().muted(),
          ),
          Expanded(
            child: Text(value).small().semiBold(),
          ),
        ],
      ),
    );
  }
}

class _ItemEditGroup {
  final String? id;
  final TextEditingController nameController;
  final TextEditingController quantityController;
  final TextEditingController priceController;
  final TextEditingController totalPriceController;
  String? categoryId;
  String? categoryName;

  _ItemEditGroup({
    this.id,
    required this.nameController,
    required this.quantityController,
    required this.priceController,
    required this.totalPriceController,
    this.categoryId,
    this.categoryName,
  });

  factory _ItemEditGroup.fromItem(ReceiptItem item) {
    return _ItemEditGroup(
      id: item.id,
      nameController: TextEditingController(text: item.name),
      quantityController: TextEditingController(text: item.quantity.toString()),
      priceController: TextEditingController(text: item.price.toStringAsFixed(0)),
      totalPriceController: TextEditingController(text: item.totalPrice.toStringAsFixed(0)),
      categoryId: item.categoryId,
      categoryName: item.categoryName,
    );
  }

  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    priceController.dispose();
    totalPriceController.dispose();
  }
}

class _ManualEditSheet extends StatefulWidget {
  final Receipt initialReceipt;
  final List<Kategori> categories;
  final ValueChanged<Receipt> onSave;

  const _ManualEditSheet({
    required this.initialReceipt,
    required this.categories,
    required this.onSave,
  });

  @override
  State<_ManualEditSheet> createState() => _ManualEditSheetState();
}

class _ManualEditSheetState extends State<_ManualEditSheet> {
  late TextEditingController _storeNameController;
  late TextEditingController _dateController;
  late TextEditingController _totalAmountController;
  String? _selectedCategoryId;
  String? _selectedCategoryName;
  late List<_ItemEditGroup> _itemGroups;

  @override
  void initState() {
    super.initState();
    _storeNameController = TextEditingController(text: widget.initialReceipt.storeName);
    _dateController = TextEditingController(text: widget.initialReceipt.date);
    _totalAmountController = TextEditingController(text: widget.initialReceipt.totalAmount.toStringAsFixed(0));
    _selectedCategoryId = widget.initialReceipt.categoryId;
    _selectedCategoryName = widget.initialReceipt.categoryName;
    _itemGroups = widget.initialReceipt.items.map((item) => _ItemEditGroup.fromItem(item)).toList();
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _dateController.dispose();
    _totalAmountController.dispose();
    for (final group in _itemGroups) {
      group.dispose();
    }
    super.dispose();
  }

  void _recalculateItemTotal(_ItemEditGroup group) {
    final qty = int.tryParse(group.quantityController.text.trim()) ?? 0;
    final price = double.tryParse(group.priceController.text.trim()) ?? 0.0;
    group.totalPriceController.text = (qty * price).toStringAsFixed(0);
    _recalculateGrandTotal();
  }

  void _recalculateGrandTotal() {
    double grandTotal = 0.0;
    for (final group in _itemGroups) {
      grandTotal += double.tryParse(group.totalPriceController.text.trim()) ?? 0.0;
    }
    _totalAmountController.text = grandTotal.toStringAsFixed(0);
    setState(() {});
  }

  void _addItem() {
    setState(() {
      _itemGroups.add(
        _ItemEditGroup(
          nameController: TextEditingController(text: ''),
          quantityController: TextEditingController(text: '1'),
          priceController: TextEditingController(text: '0'),
          totalPriceController: TextEditingController(text: '0'),
        ),
      );
    });
    _recalculateGrandTotal();
  }

  void _removeItem(int index) {
    setState(() {
      final group = _itemGroups.removeAt(index);
      group.dispose();
    });
    _recalculateGrandTotal();
  }

  void _save() {
    final items = _itemGroups.map((group) {
      final qty = int.tryParse(group.quantityController.text.trim()) ?? 1;
      final price = double.tryParse(group.priceController.text.trim()) ?? 0.0;
      final total = double.tryParse(group.totalPriceController.text.trim()) ?? (qty * price).toDouble();
      return ReceiptItem(
        id: group.id,
        name: group.nameController.text.trim().isEmpty ? 'Item Belanja' : group.nameController.text.trim(),
        quantity: qty,
        price: price,
        totalPrice: total,
        categoryId: group.categoryId,
        categoryName: group.categoryName,
      );
    }).toList();

    final total = double.tryParse(_totalAmountController.text.trim()) ??
        items.fold<double>(0.0, (sum, item) => sum + item.totalPrice);

    final updatedReceipt = widget.initialReceipt.copyWith(
      storeName: _storeNameController.text.trim().isEmpty ? 'Toko Tidak Diketahui' : _storeNameController.text.trim(),
      date: _dateController.text.trim().isEmpty ? DateTime.now().toIso8601String().split('T').first : _dateController.text.trim(),
      categoryId: _selectedCategoryId,
      categoryName: _selectedCategoryName,
      items: items,
      totalAmount: total,
    );

    widget.onSave(updatedReceipt);
    closeOverlay(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Ubah Data Struk').large().semiBold(),
              IconButton.ghost(
                icon: const Icon(LucideIcons.x, size: 20),
                onPressed: () => closeOverlay(context),
              ),
            ],
          ),
          const Gap(4),
          const Text(
            'Koreksi atau lengkapi informasi toko, tanggal, kategori, serta daftar item struk belanja secara langsung.',
          ).muted().small(),
          const Gap(16),
          const Divider(),
          const Gap(16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Informasi Umum
                  const Text('Informasi Umum').medium().semiBold(),
                  const Gap(12),
                  const Text('Nama Toko').small().medium(),
                  const Gap(6),
                  TextField(
                    controller: _storeNameController,
                    placeholder: const Text('Contoh: Indomaret, Alfamart...'),
                  ),
                  const Gap(12),
                  const Text('Tanggal Belanja').small().medium(),
                  const Gap(6),
                  TextField(
                    controller: _dateController,
                    placeholder: const Text('YYYY-MM-DD atau DD/MM/YYYY'),
                  ),
                  const Gap(12),
                  const Text('Kategori Pengeluaran').small().medium(),
                  const Gap(6),
                  Select<String>(
                    value: _selectedCategoryId,
                    placeholder: const Text('Pilih Kategori'),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategoryId = value;
                        if (value != null) {
                          final match = widget.categories.where((c) => c.id == value);
                          if (match.isNotEmpty) {
                            _selectedCategoryName = match.first.nama;
                          }
                        }
                      });
                    },
                    itemBuilder: (context, itemValue) {
                      final category = widget.categories.firstWhere(
                        (c) => c.id == itemValue,
                        orElse: () => Kategori(
                          id: '',
                          nama: _selectedCategoryName ?? 'Lainnya',
                          jenis: 'PENGELUARAN',
                          adalahPreset: true,
                        ),
                      );
                      return Text(category.nama);
                    },
                    popup: SelectPopup<String>.builder(
                      searchPlaceholder: const Text('Cari kategori...'),
                      builder: (context, searchQuery) {
                        final filtered = searchQuery == null
                            ? widget.categories
                            : widget.categories
                                .where((c) => c.nama
                                    .toLowerCase()
                                    .contains(searchQuery.toLowerCase()))
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
                  const Gap(12),
                  const Text('Total Belanja (Rp)').small().medium(),
                  const Gap(6),
                  TextField(
                    controller: _totalAmountController,
                    keyboardType: TextInputType.number,
                    placeholder: const Text('0'),
                  ),
                  const Gap(24),
                  const Divider(),
                  const Gap(16),
                  // 2. Daftar Item Struk
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Daftar Item (${_itemGroups.length})').medium().semiBold(),
                      OutlineButton(
                        size: ButtonSize.small,
                        onPressed: _addItem,
                        child: const Row(
                          children: [
                            Icon(LucideIcons.plus, size: 14),
                            Gap(6),
                            Text('Tambah Item'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Gap(12),
                  if (_itemGroups.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.muted,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('Belum ada item belanja. Klik "+ Tambah Item" untuk menambahkan.').small().muted(),
                    )
                  else
                    for (int i = 0; i < _itemGroups.length; i++)
                      _buildItemEditorCard(context, _itemGroups[i], i),
                  const Gap(16),
                ],
              ),
            ),
          ),
          const Gap(16),
          const Divider(),
          const Gap(16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SecondaryButton(
                onPressed: () => closeOverlay(context),
                child: const Text('Batal'),
              ),
              const Gap(12),
              PrimaryButton(
                onPressed: _save,
                child: const Row(
                  children: [
                    Icon(LucideIcons.check, size: 16),
                    Gap(8),
                    Text('Simpan Perubahan'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemEditorCard(BuildContext context, _ItemEditGroup group, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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
            placeholder: const Text('Nama produk atau barang'),
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
                    const Text('Harga Satuan (Rp)').xSmall().muted(),
                    const Gap(4),
                    TextField(
                      controller: group.priceController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _recalculateItemTotal(group),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(8),
          const Text('Subtotal / Total Harga Item (Rp)').xSmall().muted(),
          const Gap(4),
          TextField(
            controller: group.totalPriceController,
            keyboardType: TextInputType.number,
            onChanged: (_) => _recalculateGrandTotal(),
          ),
        ],
      ),
    ),
    );
  }
}
