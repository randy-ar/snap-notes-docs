import 'package:shadcn_flutter/shadcn_flutter.dart';

class ScanAnimationOverlay extends StatefulWidget {
  final String text;

  const ScanAnimationOverlay({super.key, required this.text});

  @override
  State<ScanAnimationOverlay> createState() => _ScanAnimationOverlayState();
}

class _ScanAnimationOverlayState extends State<ScanAnimationOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            // Gelap semi transparan
            Container(color: Colors.black.withValues(alpha: 0.5)),
            // Garis scan bergerak
            Positioned(
              top: MediaQuery.of(context).size.height * 0.8 * _controller.value,
              left: 0,
              right: 0,
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                      blurRadius: 12,
                      spreadRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
            // Teks loading di tengah
            Center(
              child: Card(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const Gap(16),
                    Text(widget.text).small().semiBold(),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
