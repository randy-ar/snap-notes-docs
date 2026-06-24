import 'package:shadcn_flutter/shadcn_flutter.dart';

class ToastFormatter {
  /// Formatter untuk pesan PP01 (Pesan Sukses)
  static Widget success(String message, [String? description]) {
    return SurfaceCard(
      child: Basic(
        leading: const Icon(
          LucideIcons.check,
          color: Color(0xFF4CAF50),
        ),
        title: Text(message),
        subtitle: description != null ? Text(description) : null,
      ),
    );
  }

  /// Formatter untuk pesan PP02 (Pesan Gagal)
  static Widget error(String message, [String? description]) {
    return SurfaceCard(
      child: Basic(
        leading: const Icon(
          LucideIcons.x,
          color: Color(0xFFF44336),
        ),
        title: Text(message),
        subtitle: description != null ? Text(description) : null,
      ),
    );
  }

  /// Formatter untuk pesan PP03 (Pesan Validasi)
  static Widget validation(String message) {
    return SurfaceCard(
      child: Basic(
        leading: const Icon(
          LucideIcons.triangleAlert,
          color: Color(0xFFFF9800),
        ),
        title: const Text('Peringatan'),
        subtitle: Text(message),
      ),
    );
  }
}
