import 'dart:io';
import 'package:flutter/material.dart'
    hide
        Stepper,
        Step,
        Positioned,
        Column,
        Expanded,
        Row,
        Stack,
        Scaffold,
        AppBar,
        IconButton,
        Theme,
        Card,
        Divider,
        TextField,
        AlertDialog,
        FormField,
        Colors,
        CircularProgressIndicator,
        showDialog;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'package:shadcn_flutter/shadcn_flutter.dart' hide Card;
import 'package:provider/provider.dart';
import 'package:snap_notes_mvvm/features/pengeluaran/models/kategori.dart';
import 'package:snap_notes_mvvm/features/receipt/models/receipt.dart';
import 'package:snap_notes_mvvm/features/receipt/viewmodels/receipt_viewmodel.dart';
import 'package:snap_notes_mvvm/utils/format_utils.dart';
import 'package:snap_notes_mvvm/core/utils/toast_formatter.dart';
import 'package:snap_notes_mvvm/features/receipt/views/pages/receipt_upload_page.dart';
import 'package:snap_notes_mvvm/features/receipt/views/widgets/scan_animation_overlay.dart';
import 'package:snap_notes_mvvm/features/receipt/views/pages/full_screen_image_page.dart';
import 'package:snap_notes_mvvm/utils/rupiah_input_formatter.dart';

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
  final StepperController _stepperController = StepperController();
  int _tabIndex = 0;
  int _selectedReceiptIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReceiptViewModel>().loadCategories();
      _stepperController.jumpToStep(2); // Jump to "Review AI" step
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
  void konfirmasiSimpan() async {
    final viewModel = context.read<ReceiptViewModel>();
    await viewModel.confirmReceipt();
    if (mounted && viewModel.currentStep == ReceiptScanStep.confirmed) {
      showToast(
        context: context,
        builder: (context, overlay) =>
            ToastFormatter.success('Struk berhasil disimpan!'),
        location: ToastLocation.bottomRight,
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider.value(
            value: viewModel,
            child: ReceiptUploadPage(
              image: widget.image,
              images: widget.images,
              receipt: widget.isBatchMode ? null : viewModel.receiptDetail,
              receipts: widget.isBatchMode ? viewModel.batchReceipts : null,
              isBatchMode: widget.isBatchMode,
              isError: false,
            ),
          ),
        ),
      );
    } else if (mounted && viewModel.errorMessage != null) {
      showToast(
        context: context,
        builder: (context, overlay) =>
            ToastFormatter.error(viewModel.errorMessage!),
        location: ToastLocation.bottomRight,
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider.value(
            value: viewModel,
            child: ReceiptUploadPage(
              image: widget.image,
              images: widget.images,
              receipt: widget.isBatchMode ? null : viewModel.receiptDetail,
              receipts: widget.isBatchMode ? viewModel.batchReceipts : null,
              isBatchMode: widget.isBatchMode,
              isError: true,
              errorMessage: viewModel.errorMessage,
            ),
          ),
        ),
      );
    }
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

    return DrawerOverlay(
      child: Stack(
        children: [
          if (widget.useScaffold)
            Scaffold(
              headers: [
                AppBar(
                  title: const Text('Scan Struk'),
                  leading: [
                    IconButton.ghost(
                      onPressed: () => viewModel.cancelScan(),
                      icon: const Icon(LucideIcons.arrowLeft),
                    ),
                  ],
                ),
              ],
              child: SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: Stepper(
                        controller: _stepperController,
                        direction: Axis.horizontal,
                        variant: StepVariant.circleAlt,
                        steps: [
                          const Step(
                            title: Text('Ambil Foto'),
                            contentBuilder: _buildEmptyStepContent,
                          ),
                          const Step(
                            title: Text('Scan Foto'),
                            contentBuilder: _buildEmptyStepContent,
                          ),
                          Step(
                            title: const Text('Review AI'),
                            contentBuilder: (context) => mainContent,
                          ),
                          const Step(
                            title: Text('Simpan Struk'),
                            contentBuilder: _buildEmptyStepContent,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            mainContent,
          if (viewModel.isLoading && !viewModel.isUploading)
            const Positioned.fill(
              child: ScanAnimationOverlay(
                text: 'Memproses ulang dengan konteks AI...',
              ),
            ),
        ],
      ),
    );
  }

  static Widget _buildEmptyStepContent(BuildContext context) =>
      const SizedBox.shrink();

  // ---------------------------------------------------------------------------
  // Single-mode content
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
                          : () => _openManualEditSheet(
                              context,
                              viewModel,
                              receipt,
                              null,
                            ),
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
                  onPressed: viewModel.isLoading || viewModel.isUploading
                      ? null
                      : () => konfirmasiSimpan(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (viewModel.isUploading)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(),
                        )
                      else
                        const Icon(LucideIcons.check),
                      const Gap(8),
                      Text(viewModel.isUploading ? 'Menyimpan...' : 'Simpan Data'),
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
              Text(
                'Struk ${_selectedReceiptIndex + 1} dari ${receipts.length}',
              ).medium().semiBold(),
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
                            title: 'Foto Struk ${_selectedReceiptIndex + 1}',
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
                child: Builder(
                  builder: (context) {
                    return SecondaryButton(
                      onPressed: viewModel.isLoading || currentReceipt == null
                          ? null
                          : () => _openManualEditSheet(
                              context,
                              viewModel,
                              currentReceipt,
                              _selectedReceiptIndex,
                            ),
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
                  onPressed: viewModel.isLoading || viewModel.isUploading
                      ? null
                      : () => konfirmasiSimpan(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (viewModel.isUploading)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(),
                        )
                      else
                        const Icon(LucideIcons.check, size: 16),
                      const Gap(8),
                      Text(viewModel.isUploading ? 'Menyimpan...' : 'Simpan Semua'),
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _ManualEditSheet(
          initialReceipt: initialReceipt,
          categories: viewModel.categories,
          onSave: (updatedReceipt) {
            viewModel.updateReceiptManual(
              updatedReceipt,
              batchIndex: batchIndex,
            );
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
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: Theme.of(context).colorScheme.primary,
            size: 32,
          ),
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
                const Text(
                  'AI berhasil menguraikan data struk belanja Anda.',
                ).xSmall().muted(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParsedReceipt(BuildContext context, Receipt receipt) {
    return shadcn.Card(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Data Struk:').small().semiBold(),
          const Gap(12),
          _buildDataRow('Nama Toko', receipt.storeName),
          _buildDataRow('Kategori', receipt.categoryName ?? 'Lainnya'),
          _buildDataRow(
            'Tanggal',
            FormatUtils.formatIndonesianDate(DateTime.tryParse(receipt.date)),
          ),
          if (receipt.discount != null && receipt.discount! > 0)
            _buildDataRow(
              'Diskon',
              FormatUtils.formatRupiah(receipt.discount!),
            ),
          _buildDataRow('Total Items', FormatUtils.formatRupiah(receipt.totalItemAmount ?? receipt.totalAmount)),
          _buildDataRow('Total', FormatUtils.formatRupiah(receipt.totalAmount)),
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
                      Text(
                        '${FormatUtils.formatDecimalRibuan(item.quantity)} x ${FormatUtils.formatRupiah(item.price)}',
                      ).xSmall().muted(),
                      Text(
                        FormatUtils.formatRupiah(item.totalPrice),
                      ).small().semiBold(),
                    ],
                  ),
                  if (item.discount != null && item.discount! > 0)
                    Text(
                      'Diskon: ${FormatUtils.formatRupiah(item.discount!)}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ).xSmall(),
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
          SizedBox(width: 100, child: Text(label).xSmall().muted()),
          Expanded(child: Text(value).small().semiBold()),
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
    return _ItemEditGroup(
      id: item.id,
      nameController: TextEditingController(text: item.name),
      quantityController: TextEditingController(
        text: FormatUtils.formatDecimalRibuan(item.quantity),
      ),
      priceController: TextEditingController(
        text: FormatUtils.formatDecimalRibuan(item.price),
      ),
      discountController: TextEditingController(
        text: item.discount != null && item.discount! > 0
            ? FormatUtils.formatDecimalRibuan(item.discount)
            : '',
      ),
      totalPriceController: TextEditingController(
        text: FormatUtils.formatDecimalRibuan(item.totalPrice),
      ),
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
  late TextEditingController _totalItemAmountController;
  String? _selectedCategoryId;
  String? _selectedCategoryName;
  late List<_ItemEditGroup> _itemGroups;

  @override
  void initState() {
    super.initState();
    _storeNameController = TextEditingController(
      text: widget.initialReceipt.storeName,
    );
    _dateController = TextEditingController(text: widget.initialReceipt.date);
    _totalItemAmountController = TextEditingController(
      text: FormatUtils.formatDecimalRibuan(
          widget.initialReceipt.totalItemAmount ?? widget.initialReceipt.totalAmount),
    );
    _selectedCategoryId = widget.initialReceipt.categoryId;
    _selectedCategoryName = widget.initialReceipt.categoryName;
    _itemGroups = widget.initialReceipt.items
        .map((item) => _ItemEditGroup.fromItem(item))
        .toList();
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _dateController.dispose();
    _totalItemAmountController.dispose();
    for (final group in _itemGroups) {
      group.dispose();
    }
    super.dispose();
  }

  void _recalculateItemTotal(_ItemEditGroup group) {
    final qty = FormatUtils.parseRupiahToDouble(
      group.quantityController.text,
    ).toInt();
    final price = FormatUtils.parseRupiahToDouble(group.priceController.text);
    final discount = FormatUtils.parseRupiahToDouble(
      group.discountController.text,
    );
    final total = (qty * price) - discount;
    group.totalPriceController.text = FormatUtils.formatDecimalRibuan(total);
    _recalculateGrandTotal();
  }

  void _recalculateGrandTotal() {
    double totalItemAmount = 0.0;
    for (final group in _itemGroups) {
      final qty = FormatUtils.parseRupiahToDouble(group.quantityController.text).toInt();
      final price = FormatUtils.parseRupiahToDouble(group.priceController.text);
      totalItemAmount += (qty * price);
    }
    _totalItemAmountController.text = FormatUtils.formatDecimalRibuan(totalItemAmount);
  }

  void _addItem() {
    setState(() {
      _itemGroups.insert(
        0,
        _ItemEditGroup(
          nameController: TextEditingController(text: ''),
          quantityController: TextEditingController(text: ''),
          priceController: TextEditingController(text: ''),
          discountController: TextEditingController(text: ''),
          totalPriceController: TextEditingController(text: ''),
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

  void _save(BuildContext context, Map<FormKey<dynamic>, dynamic> values) {
    if (_itemGroups.isEmpty) {
      shadcn.showToast(
        context: context,
        builder: (context, overlay) => shadcn.SurfaceCard(
          child: shadcn.Basic(
            title: const Text('Struk Kosong'),
            subtitle: const Text('Setiap struk wajib memiliki minimal 1 item.'),
            trailing: shadcn.IconButton.ghost(
              icon: const Icon(LucideIcons.x),
              onPressed: () => overlay.close(),
            ),
          ),
        ),
        location: shadcn.ToastLocation.bottomRight,
      );
      return;
    }
    final items = _itemGroups.map((group) {
      final qty = int.tryParse(group.quantityController.text.trim()) ?? 1;
      final price = FormatUtils.parseRupiahToDouble(
        group.priceController.text.trim(),
      );
      final discount = FormatUtils.parseRupiahToDouble(
        group.discountController.text.trim(),
      );
      final total = FormatUtils.parseRupiahToDouble(
        group.totalPriceController.text.trim(),
      );
      return ReceiptItem(
        id: group.id,
        name: group.nameController.text.trim().isEmpty
            ? 'Item Belanja'
            : group.nameController.text.trim(),
        quantity: qty,
        price: price,
        discount: discount > 0 ? discount : null,
        totalPrice: total,
        categoryId: group.categoryId,
        categoryName: group.categoryName,
      );
    }).toList();

    double totalDiscount = 0.0;
    double grandTotal = 0.0;

    for (final group in _itemGroups) {
      totalDiscount += FormatUtils.parseRupiahToDouble(
        group.discountController.text,
      );
      grandTotal += FormatUtils.parseRupiahToDouble(
        group.totalPriceController.text,
      );
    }

    final total = grandTotal;

    final totalItemAmount = FormatUtils.parseRupiahToDouble(
      _totalItemAmountController.text.trim(),
    );

    final updatedReceipt = widget.initialReceipt.copyWith(
      storeName: _storeNameController.text.trim().isEmpty
          ? 'Toko Tidak Diketahui'
          : _storeNameController.text.trim(),
      date: _dateController.text.trim(),
      categoryId: _selectedCategoryId,
      categoryName: _selectedCategoryName,
      items: items,
      discount: totalDiscount > 0 ? totalDiscount : null,
      totalAmount: total,
      totalItemAmount: totalItemAmount,
    );

    widget.onSave(updatedReceipt);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
        maxWidth: 600,
      ),
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: 24 + bottomInset,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
      ),
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
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const Gap(4),
          const Text(
            'Koreksi atau lengkapi informasi toko, tanggal, kategori, serta daftar item struk belanja secara langsung.',
          ).muted().small(),
          const Gap(16),
          Expanded(
            child: shadcn.Form(
              onSubmit: _save,
              child: Builder(
                builder: (formContext) => SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Gap(16),
                      const Text('Informasi Umum').medium().semiBold(),
                      const Gap(16),
                      shadcn.FormField(
                        key: const shadcn.TextFieldKey('storeName'),
                        label: const Text('Nama Toko').small().medium(),
                        validator: const shadcn.NotEmptyValidator(message: 'Nama toko tidak boleh kosong'),
                        showErrors: const {shadcn.FormValidationMode.changed, shadcn.FormValidationMode.submitted},
                        child: shadcn.TextField(
                          controller: _storeNameController,
                          placeholder: const Text('Contoh: Indomaret, Alfamart...'),
                        ),
                      ),
                      const Gap(16),
                      shadcn.FormField(
                        key: const shadcn.DatePickerKey('date'),
                        label: const Text('Tanggal Belanja').small().medium(),
                        validator: const shadcn.NonNullValidator(message: 'Tanggal tidak boleh kosong'),
                        showErrors: const {shadcn.FormValidationMode.changed, shadcn.FormValidationMode.submitted},
                        child: shadcn.DatePicker(
                          value:
                              DateTime.tryParse(_dateController.text.trim()) ??
                              DateTime.now(),
                          onChanged: (DateTime? date) {
                            if (date != null) {
                              _dateController.text = date
                                  .toIso8601String()
                                  .split('T')
                                  .first;
                            }
                          },
                          placeholder: const Text('Pilih Tanggal Belanja'),
                        ),
                      ),
                      const Gap(12),
	                  shadcn.FormField<String>(
	                    key: const shadcn.SelectKey<String>('category'),
	                    showErrors: const {shadcn.FormValidationMode.changed, shadcn.FormValidationMode.submitted},
	                    label: const Text('Kategori Pengeluaran').small().medium(),
	                    child: Select<String>(
	                    value: _selectedCategoryId,
	                    placeholder: const Text('Pilih Kategori'),
	                    onChanged: (value) {
	                      setState(() {
	                        _selectedCategoryId = value;
	                        if (value != null) {
	                          final match = widget.categories.where(
	                            (c) => c.id == value,
	                          );
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
	                                  .where(
	                                    (c) => c.nama.toLowerCase().contains(
	                                      searchQuery.toLowerCase(),
	                                    ),
	                                  )
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
	                  const Gap(12),
	                  shadcn.FormField(
	                    key: const shadcn.TextFieldKey('totalItemAmount'),
	                    label: const Text('Total Items (Rp)').small().medium(),
	                    showErrors: const {shadcn.FormValidationMode.changed, shadcn.FormValidationMode.submitted},
	                    validator: const shadcn.NotEmptyValidator(message: 'Total items tidak boleh kosong') &
	                        shadcn.ValidationMode(
	                          shadcn.ConditionalValidator((value) async {
	                            if (value == null) return false;
	                            final doubleVal = FormatUtils.parseRupiahToDouble(value);
	                            return doubleVal > 0;
	                          }, message: 'Total items harus lebih besar dari 0'),
	                          mode: {shadcn.FormValidationMode.submitted},
	                        ),
	                    child: TextField(
	                      controller: _totalItemAmountController,
	                      keyboardType: TextInputType.number,
	                      inputFormatters: [RupiahInputFormatter()],
	                      placeholder: const Text('0'),
	                      readOnly: true,
	                      features: [
	                        shadcn.InputLeadingFeature(
	                          Text(
	                            'Rp',
	                            style: TextStyle(
	                              color: Theme.of(context).colorScheme.mutedForeground,
	                            ),
	                          ),
	                        ),
	                      ],
	                    ),
	                  ),
                  const Gap(16),
                  const Divider(),
                  const Gap(16),
                  // 2. Daftar Item Struk
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Daftar Item (${_itemGroups.length})',
                      ).medium().semiBold(),
                      shadcn.OutlineButton(
                        size: shadcn.ButtonSize.small,
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
                      child: const Text(
                        'Belum ada item belanja. Klik "+ Tambah Item" untuk menambahkan.',
                      ).small().muted(),
                    )
                  else
                    for (int i = 0; i < _itemGroups.length; i++)
                      _buildItemEditorCard(context, _itemGroups[i], i),
                  const Gap(16),
                  const Divider(),
                  const Gap(16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      shadcn.SecondaryButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Batal'),
                      ),
                      const Gap(12),
                      const shadcn.SubmitButton(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
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
            ),
          ),
        ),
      ),
    ],
    ),
    );
  }

  Widget _buildItemEditorCard(
    BuildContext context,
    _ItemEditGroup group,
    int index,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: shadcn.Card(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Item #${index + 1}').small().semiBold(),
                shadcn.IconButton.ghost(
                  size: shadcn.ButtonSize.small,
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
            shadcn.FormField(
              key: shadcn.TextFieldKey('itemName_$index'),
              label: const Text('Nama Item').xSmall().muted(),
              validator: const shadcn.NotEmptyValidator(message: 'Nama item tidak boleh kosong'),
              showErrors: const {shadcn.FormValidationMode.changed, shadcn.FormValidationMode.submitted},
              child: shadcn.TextField(
                controller: group.nameController,
                placeholder: const Text('Nama produk atau barang'),
              ),
            ),
            const Gap(8),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      shadcn.FormField(
                        key: shadcn.TextFieldKey('itemQty_$index'),
                        label: const Text('Jumlah').xSmall().muted(),
                        validator: const shadcn.NotEmptyValidator(message: 'Jumlah tidak boleh kosong'),
                        showErrors: const {shadcn.FormValidationMode.changed, shadcn.FormValidationMode.submitted},
                        child: shadcn.TextField(
                          controller: group.quantityController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [RupiahInputFormatter()],
                          onChanged: (_) => _recalculateItemTotal(group),
                        ),
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
                      shadcn.FormField(
                        key: shadcn.TextFieldKey('itemPrice_$index'),
                        label: const Text('Harga Satuan (Rp)').xSmall().muted(),
                        validator: const shadcn.NotEmptyValidator(message: 'Harga tidak boleh kosong'),
                        showErrors: const {shadcn.FormValidationMode.changed, shadcn.FormValidationMode.submitted},
                        child: shadcn.TextField(
                          controller: group.priceController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [RupiahInputFormatter()],
                          onChanged: (_) => _recalculateItemTotal(group),
                          features: [
                            shadcn.InputLeadingFeature(
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 12.0,
                                  right: 8.0,
                                ),
                                child: Text(
                                  'Rp',
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.mutedForeground,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(8),
            shadcn.FormField(
              key: shadcn.TextFieldKey('itemDiscount_$index'),
              label: const Text('Diskon Item (Rp)').xSmall().muted(),
              showErrors: const {shadcn.FormValidationMode.changed, shadcn.FormValidationMode.submitted},
              child: shadcn.TextField(
                controller: group.discountController,
                keyboardType: TextInputType.number,
                inputFormatters: [RupiahInputFormatter()],
                onChanged: (_) => _recalculateItemTotal(group),
                placeholder: const Text('Opsional'),
                features: [
                  shadcn.InputLeadingFeature(
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0, right: 8.0),
                      child: Text(
                        'Rp',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.mutedForeground,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Gap(8),
            const Text('Subtotal / Total Harga Item (Rp)').xSmall().muted(),
            const Gap(4),
            shadcn.TextField(
              controller: group.totalPriceController,
              keyboardType: TextInputType.number,
              inputFormatters: [RupiahInputFormatter()],
              onChanged: (_) => _recalculateGrandTotal(),
              readOnly: true,
              features: [
                shadcn.InputLeadingFeature(
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0, right: 8.0),
                    child: Text(
                      'Rp',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.mutedForeground,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
