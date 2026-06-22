import 'dart:io';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:snap_notes_mvvm/features/receipt/models/receipt.dart';
import 'package:snap_notes_mvvm/features/receipt/viewmodels/receipt_viewmodel.dart';
import 'package:snap_notes_mvvm/features/receipt/views/widgets/scan_animation_overlay.dart';

class ResponsePreviewPage extends StatefulWidget {
  final File image;
  final Receipt receipt;
  final bool useScaffold;

  const ResponsePreviewPage({
    super.key,
    required this.image,
    required this.receipt,
    this.useScaffold = true,
  });

  @override
  State<ResponsePreviewPage> createState() => _ResponsePreviewPageState();
}

class _ResponsePreviewPageState extends State<ResponsePreviewPage> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ReceiptViewModel>();
    final responseMap = widget.receipt.toJson();

    final mainContent = Column(
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
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.muted,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          widget.image,
                          width: double.infinity,
                          fit: BoxFit.fitWidth,
                          alignment: Alignment.center,
                        ),
                      ),
                    ),
                    
                    // Tab 1: Data Struk
                    _buildParsedReceipt(context, responseMap),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Action Buttons
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Builder(
                  builder: (context) {
                    return SecondaryButton(
                      onPressed: viewModel.isLoading ? null : () {
                        _showKoreksiDrawer(context, viewModel);
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.sparkles),
                          Gap(8),
                          Text('Ubah Data'),
                        ],
                      ),
                    );
                  }
                ),
              ),
              const Gap(16),
              Expanded(
                child: PrimaryButton(
                  onPressed: viewModel.isLoading ? null : () => viewModel.confirmReceipt(),
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

    return Stack(
      children: [
        if (widget.useScaffold)
          Scaffold(
            headers: [
              AppBar(
                title: const Text('Review Hasil Scan'),
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
            child: ScanAnimationOverlay(text: 'Memproses ulang dengan konteks AI...'),
          ),
      ],
    );
  }

  void _showKoreksiDrawer(BuildContext context, ReceiptViewModel viewModel) {
    final promptController = TextEditingController();

    openDrawer(
      context: context,
      position: OverlayPosition.bottom,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Beri Konteks AI').large().semiBold(),
              const Gap(8),
              const Text('Berikan instruksi tambahan jika hasil ekstraksi dari AI kurang tepat. Contoh: "Ini adalah struk tagihan internet bulanan"').muted(),
              const Gap(16),
              TextField(
                controller: promptController,
                maxLines: 3,
                placeholder: const Text('Masukkan konteks atau koreksi Anda di sini...'),
              ),
              const Gap(24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SecondaryButton(
                    onPressed: () => closeOverlay(context),
                    child: const Text('Tutup'),
                  ),
                  const Gap(12),
                  PrimaryButton(
                    onPressed: () {
                      final prompt = promptController.text.trim();
                      if (prompt.isNotEmpty) {
                        closeOverlay(context);
                        viewModel.reparseReceipt(prompt);
                      }
                    },
                    child: const Text('Proses Ulang'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSuccessBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary, size: 32),
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
                const Text('AI berhasil menguraikan data struk belanja Anda.').xSmall().muted(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParsedReceipt(BuildContext context, Map<String, dynamic> responseMap) {
    return Card(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Data Struk:').small().semiBold(),
          const Gap(12),
          _buildDataRow('Nama Toko', widget.receipt.storeName),
          _buildDataRow('Kategori', widget.receipt.categoryName ?? 'Lainnya'),
          _buildDataRow('Tanggal', widget.receipt.date),
          _buildDataRow('Total', 'Rp ${widget.receipt.totalAmount.toStringAsFixed(0)}'),
          const Gap(16),
          const Divider(),
          const Gap(16),
          const Text('Item Belanja:').small().semiBold(),
          const Gap(12),
          ...widget.receipt.items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name).small().semiBold(),
                const Gap(4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${item.quantity} x Rp ${item.price.toStringAsFixed(0)}').xSmall().muted(),
                    Text('Rp ${item.totalPrice.toStringAsFixed(0)}').small().semiBold(),
                  ],
                ),
              ],
            ),
          )),
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
