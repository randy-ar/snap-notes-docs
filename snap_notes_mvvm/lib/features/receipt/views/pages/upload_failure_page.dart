import 'dart:convert';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:snap_notes_mvvm/core/utils/toast_formatter.dart';
import 'package:snap_notes_mvvm/features/receipt/viewmodels/receipt_viewmodel.dart';

class UploadFailurePage extends StatelessWidget {
  final String message;
  final String? stackTrace;
  final Map<String, dynamic>? serverResponse;
  final int? statusCode;
  final bool useScaffold;

  const UploadFailurePage({
    super.key,
    required this.message,
    this.stackTrace,
    this.serverResponse,
    this.statusCode,
    this.useScaffold = true,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ReceiptViewModel>();

    final mainContent = Column(
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
                    color: Theme.of(context).colorScheme.destructive.withValues(alpha: 0.1),
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
                    color: statusCode != null && statusCode! >= 500
                        ? Theme.of(context).colorScheme.destructive
                        : const Color(0xFFFF9800),
                  ),
                ),
                const Gap(8),
                Text(
                  message,
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
                          Icon(LucideIcons.info, color: Theme.of(context).colorScheme.primary),
                          const Gap(8),
                          const Text('Detail Error').small().semiBold(),
                          const Spacer(),
                          if (serverResponse != null)
                            OutlineButton(
                              onPressed: () {
                                final jsonStr = const JsonEncoder.withIndent('  ').convert(serverResponse);
                                Clipboard.setData(ClipboardData(text: jsonStr));
                                showToast(
                                  context: context,
                                  builder: (context, overlay) => ToastFormatter.success('Detail error disalin ke clipboard'),
                                  location: ToastLocation.bottomRight,
                                );
                              },
                              child: const Icon(LucideIcons.copy),
                            ),
                        ],
                      ),
                      const Gap(16),
                      // Status Code
                      if (statusCode != null)
                        _buildErrorRow(context, 'Status Code', statusCode.toString()),
                      // Server Response
                      if (serverResponse != null) ...[
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
                              const JsonEncoder.withIndent('  ').convert(serverResponse),
                              style: Theme.of(context).typography.xSmall.copyWith(
                                fontFamily: 'monospace',
                                color: Theme.of(context).colorScheme.destructive,
                              ),
                            ),
                          ),
                        ),
                      ],
                      // Stack Trace
                      if (stackTrace != null) ...[
                        const Gap(16),
                        const Text('Stack Trace:').small().bold(),
                        const Gap(8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.muted,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Theme.of(context).colorScheme.border),
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Text(
                              stackTrace!,
                              style: Theme.of(context).typography.xSmall.copyWith(
                                fontFamily: 'monospace',
                                color: Theme.of(context).colorScheme.mutedForeground,
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
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Card(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Icon(Icons.help_outline, color: Theme.of(context).colorScheme.primary),
                        const Gap(12),
                        Expanded(
                          child: Text('Pastikan koneksi internet stabil dan coba lagi. Jika masalah berlanjut, hubungi tim support.').xSmall(),
                        ),
                      ],
                    ),
                  ),
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
                child: SecondaryButton(
                  onPressed: () => viewModel.startCamera(),
                  child: const Text('Kembali ke Kamera'),
                ),
              ),
              const Gap(16),
              Expanded(
                child: PrimaryButton(
                  onPressed: () => viewModel.cancelScan(),
                  child: const Text('Tutup'),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    if (!useScaffold) {
      return mainContent;
    }

    return Scaffold(
      headers: [
        AppBar(
          title: const Text('Upload Gagal'),
        ),
      ],
      child: mainContent,
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
