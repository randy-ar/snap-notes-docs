import 'dart:io';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class FullScreenImagePage extends StatelessWidget {
  final String? imageUrl;
  final File? imageFile;
  final String title;

  const FullScreenImagePage({
    super.key,
    this.imageUrl,
    this.imageFile,
    this.title = 'Gambar Struk',
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: const ThemeData.dark(),
      child: Scaffold(
        headers: [
          AppBar(
            title: Text(title),
            subtitle: const SizedBox.shrink(),
            leading: [
              IconButton.ghost(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(LucideIcons.arrowLeft),
              ),
            ],
          ),
        ],
        child: Container(
          color: Colors.black,
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 5.0,
                  child: Hero(
                    tag: imageUrl ?? imageFile?.path ?? 'receipt_image',
                    child: _buildImage(context),
                  ),
                ),
              ),
              Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.zoomIn, size: 16, color: Color(0xB3FFFFFF)),
                        const Gap(8),
                        Text(
                          'Cubit untuk memperbesar / memperkecil',
                          style: Theme.of(context).typography.xSmall.copyWith(color: const Color(0xB3FFFFFF)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    if (imageFile != null) {
      return Image.file(
        imageFile!,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
      );
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        errorBuilder: (context, error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.imageOff, color: Theme.of(context).colorScheme.mutedForeground, size: 48),
              const Gap(16),
              const Text('Gagal memuat gambar').muted(),
            ],
          ),
        ),
      );
    } else {
      return Center(
        child: Icon(LucideIcons.imageOff, color: Theme.of(context).colorScheme.mutedForeground, size: 48),
      );
    }
  }
}
