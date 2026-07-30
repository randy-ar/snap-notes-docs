import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart' hide Stepper, Step, Column, Row, Expanded, Stack, Scaffold, AppBar, Theme, Card, Divider;
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:snap_notes_mvvm/core/utils/toast_formatter.dart';
import 'package:snap_notes_mvvm/features/receipt/models/receipt.dart';
import 'package:snap_notes_mvvm/features/receipt/viewmodels/receipt_viewmodel.dart';
import 'package:snap_notes_mvvm/utils/format_utils.dart';
import 'package:snap_notes_mvvm/features/receipt/views/pages/receipt_scan_page.dart';

class ReceiptUploadPage extends StatefulWidget {
  final File? image;
  final List<File>? images;
  final Receipt? receipt;
  final List<Receipt>? receipts;
  final bool isBatchMode;
  final bool isError;
  final String? errorMessage;
  final String? stackTrace;
  final Map<String, dynamic>? serverResponse;
  final int? statusCode;
  final bool useScaffold;

  const ReceiptUploadPage({
    super.key,
    this.image,
    this.images,
    this.receipt,
    this.receipts,
    this.isBatchMode = false,
    this.isError = false,
    this.errorMessage,
    this.stackTrace,
    this.serverResponse,
    this.statusCode,
    this.useScaffold = true,
  });

  @override
  State<ReceiptUploadPage> createState() => _ReceiptUploadPageState();
}

class _ReceiptUploadPageState extends State<ReceiptUploadPage> {
  final StepperController _stepperController = StepperController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _stepperController.jumpToStep(3); // Jump to "Simpan Struk" step
    });
  }

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Builds and returns the appropriate content based on [widget.isError].
  void tampilkanHasilUpload() {
    // Triggered implicitly via build(); kept as an explicit entry-point so
    // callers can invoke it programmatically (e.g. after retry).
    setState(() {});
  }

  /// Restarts the camera for another scan.
  void scanLagi() {
    final viewModel = context.read<ReceiptViewModel>();
    viewModel.startCamera();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const ReceiptScanPage()),
    );
  }

  /// Navigates to the Dashboard/Main page.
  void selesai() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final mainContent = widget.isError
        ? _buildErrorContent(context)
        : _buildSuccessContent(context);

    if (!widget.useScaffold) {
      return mainContent;
    }

    return Scaffold(
      headers: [
        AppBar(
          title: const Text('Scan Struk'),
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
                  const Step(
                    title: Text('Review AI'),
                    contentBuilder: _buildEmptyStepContent,
                  ),
                  Step(
                    title: const Text('Simpan Struk'),
                    icon: !widget.isError
                        ? const StepNumber(icon: Icon(LucideIcons.check))
                        : const StepNumber(icon: Icon(LucideIcons.x)),
                    contentBuilder: (context) => mainContent,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildEmptyStepContent(BuildContext context) => const SizedBox.shrink();

  // ---------------------------------------------------------------------------
  // Success UI
  // ---------------------------------------------------------------------------

  Widget _buildSuccessContent(BuildContext context) {
    final viewModel = context.watch<ReceiptViewModel>();
    final isBatch = widget.images != null &&
        widget.images!.length > 1 &&
        widget.receipts != null &&
        widget.receipts!.length > 1;

    final currentImage = isBatch
        ? widget.images![_currentIndex]
        : (widget.image ??
            (widget.images?.isNotEmpty == true
                ? widget.images!.first
                : File('')));

    final currentReceipt = isBatch
        ? widget.receipts![_currentIndex]
        : (widget.receipt ??
            (widget.receipts?.isNotEmpty == true
                ? widget.receipts!.first
                : Receipt(
                    id: '',
                    totalAmount: 0,
                    date: '',
                    createdAt: DateTime.now(),
                    storeName: 'Toko Tidak Diketahui',
                    items: const [],
                  )));

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Success Banner
                _buildSuccessBanner(context),
                if (isBatch) ...[
                  const Gap(16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Struk ${_currentIndex + 1} dari ${widget.receipts!.length}')
                          .medium()
                          .semiBold(),
                      Row(
                        children: [
                          OutlineButton(
                            onPressed: _currentIndex > 0
                                ? () => setState(() => _currentIndex--)
                                : null,
                            size: ButtonSize.small,
                            child: const Icon(LucideIcons.chevronLeft, size: 16),
                          ),
                          const Gap(8),
                          OutlineButton(
                            onPressed:
                                _currentIndex < widget.receipts!.length - 1
                                    ? () => setState(() => _currentIndex++)
                                    : null,
                            size: ButtonSize.small,
                            child: const Icon(LucideIcons.chevronRight, size: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
                const Gap(24),

                // Gambar struk
                const Text('Gambar Struk:').small().semiBold(),
                const Gap(8),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.muted,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      currentImage,
                      height: 300,
                      fit: BoxFit.contain,
                      alignment: Alignment.center,
                    ),
                  ),
                ),
                const Gap(24),

                // Receipt Summary Card
                Card(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Ringkasan Struk').small().semiBold(),
                      const Gap(16),
                      _buildInfoRow(context, 'Nama Toko', currentReceipt.storeName),
                      _buildInfoRow(context, 'Kategori', currentReceipt.categoryName ?? 'Lainnya'),
                      _buildInfoRow(context, 'Tanggal', FormatUtils.formatIndonesianDate(DateTime.tryParse(currentReceipt.date))),
                      _buildInfoRow(context, 'Total Items', FormatUtils.formatRupiah(currentReceipt.totalItemAmount ?? currentReceipt.totalAmount)),
                      if (currentReceipt.discount != null && currentReceipt.discount! > 0)
                        _buildInfoRow(context, 'Diskon', '-${FormatUtils.formatRupiah(currentReceipt.discount!)}'),
                      _buildInfoRow(context, 'Total', FormatUtils.formatRupiah(currentReceipt.totalAmount)),
                      const Gap(16),
                      const Divider(),
                      const Gap(16),
                      const Text('Items:').small().semiBold(),
                      const Gap(8),
                      ...currentReceipt.items.map((item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text('${item.name} (x${FormatUtils.formatDecimalRibuan(item.quantity)})').small(),
                                    ),
                                    Text(FormatUtils.formatRupiah(item.totalPrice)).small().semiBold(),
                                  ],
                                ),
                                if (item.discount != null && item.discount! > 0)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Diskon Item').xSmall().muted(),
                                        Text(
                                          '-${FormatUtils.formatRupiah(item.discount!)}',
                                          style: Theme.of(context).typography.xSmall.copyWith(
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Action Buttons — Success
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  onPressed: selesai,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.check),
                      Gap(8),
                      Text('Selesai'),
                    ],
                  ),
                ),
              ),
              const Gap(16),
              Expanded(
                child: PrimaryButton(
                  onPressed: scanLagi,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.camera),
                      Gap(8),
                      Text('Scan Lagi'),
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
  // Error UI
  // ---------------------------------------------------------------------------

  Widget _buildErrorContent(BuildContext context) {
    final viewModel = context.watch<ReceiptViewModel>();

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Gap(32),
                // Error Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .destructive
                        .withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline,
                    color: Theme.of(context).colorScheme.destructive,
                    size: 64,
                  ),
                ),
                const Gap(24),
                // Error Message
                Text(
                  'Upload Gagal',
                  style: Theme.of(context).typography.large.copyWith(
                        fontWeight: FontWeight.bold,
                        color: widget.statusCode != null &&
                                widget.statusCode! >= 500
                            ? Theme.of(context).colorScheme.destructive
                            : const Color(0xFFFF9800),
                      ),
                ),
                const Gap(8),
                Text(
                  widget.errorMessage ?? 'Terjadi kesalahan yang tidak diketahui.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).typography.small.copyWith(
                        color: Theme.of(context).colorScheme.mutedForeground,
                      ),
                ),
                const Gap(32),
                // Error Details Card
                Card(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(LucideIcons.info,
                              color: Theme.of(context).colorScheme.primary),
                          const Gap(8),
                          const Text('Detail Error').small().semiBold(),
                          const Spacer(),
                          if (widget.serverResponse != null)
                            OutlineButton(
                              onPressed: () {
                                final jsonStr =
                                    const JsonEncoder.withIndent('  ')
                                        .convert(widget.serverResponse);
                                Clipboard.setData(
                                    ClipboardData(text: jsonStr));
                                showToast(
                                  context: context,
                                  builder: (context, overlay) =>
                                      ToastFormatter.success(
                                          'Detail error disalin ke clipboard'),
                                  location: ToastLocation.bottomRight,
                                );
                              },
                              child: const Icon(LucideIcons.copy),
                            ),
                        ],
                      ),
                      const Gap(16),
                      // Status Code
                      if (widget.statusCode != null)
                        _buildErrorRow(
                            context, 'Status Code', widget.statusCode.toString()),
                      // Server Response
                      if (widget.serverResponse != null) ...[
                        const Gap(12),
                        const Text('Server Response:').small().bold(),
                        const Gap(8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Text(
                              const JsonEncoder.withIndent('  ')
                                  .convert(widget.serverResponse),
                              style:
                                  Theme.of(context).typography.xSmall.copyWith(
                                        fontFamily: 'monospace',
                                        color: Theme.of(context)
                                            .colorScheme
                                            .destructive,
                                      ),
                            ),
                          ),
                        ),
                      ],
                      // Stack Trace
                      if (widget.stackTrace != null) ...[
                        const Gap(16),
                        const Text('Stack Trace:').small().bold(),
                        const Gap(8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.muted,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: Theme.of(context).colorScheme.border),
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Text(
                              widget.stackTrace!,
                              style:
                                  Theme.of(context).typography.xSmall.copyWith(
                                        fontFamily: 'monospace',
                                        color: Theme.of(context)
                                            .colorScheme
                                            .mutedForeground,
                                      ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Gap(16),
                // Help Card
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Card(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Icon(Icons.help_outline,
                            color: Theme.of(context).colorScheme.primary),
                        const Gap(12),
                        Expanded(
                          child: Text(
                                  'Pastikan koneksi internet stabil dan coba lagi. Jika masalah berlanjut, hubungi tim support.')
                              .xSmall(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Action Buttons — Error
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  onPressed: scanLagi,
                  child: const Text('Kembali ke Kamera'),
                ),
              ),
              const Gap(16),
              Expanded(
                child: PrimaryButton(
                  onPressed: selesai,
                  child: const Text('Tutup'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Shared helpers
  // ---------------------------------------------------------------------------

  Widget _buildSuccessBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color:
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)),
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
                  'Data Tersimpan!',
                  style: Theme.of(context).typography.base.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                const Text(
                        'Struk belanja Anda berhasil dikonfirmasi dan disimpan.')
                    .xSmall()
                    .muted(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text('$label:').xSmall().medium().muted(),
          ),
          Expanded(
            child: Text(value).xSmall().medium(),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text('$label:').xSmall().medium().muted(),
          ),
          Expanded(
            child: Text(value).xSmall().medium(),
          ),
        ],
      ),
    );
  }
}
