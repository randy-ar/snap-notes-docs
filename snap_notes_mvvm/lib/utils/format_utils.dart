import 'package:intl/intl.dart';

class FormatUtils {
  /// Memformat angka (int/double) menjadi format tampilan Rupiah (misal: Rp 12.345).
  /// Jika nilainya null, akan mengembalikan 'Rp 0'.
  static String formatRupiah(num? value) {
    if (value == null) {
      return 'Rp 0';
    }
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(value);
  }

  /// Memformat angka (int/double) menjadi format decimal ribuan (misal: 1.000).
  /// Jika nilainya null, akan mengembalikan '0'.
  static String formatDecimalRibuan(num? value) {
    if (value == null) {
      return '0';
    }
    final formatter = NumberFormat.decimalPattern('id_ID');
    return formatter.format(value);
  }

  /// Memformat DateTime menjadi string tanggal berbahasa Indonesia (misal: 12 Juli 2026).
  /// Jika nilainya null, akan mengembalikan tanda strip '-'.
  static String formatIndonesianDate(DateTime? date) {
    if (date == null) {
      return '-';
    }
    final formatter = DateFormat('d MMMM yyyy', 'id_ID');
    return formatter.format(date);
  }

  /// Formatter DateFormat untuk keperluan widget seperti DatePicker.
  static DateFormat get indonesianDateFormat => DateFormat('d MMMM yyyy', 'id_ID');

  /// Mem-parse string nominal Rupiah (misal: "Rp 12.345" atau "12.345") menjadi double.
  /// Fungsi ini menghapus semua karakter non-angka sehingga aman dari tanda minus atau simbol mata uang.
  static double parseRupiahToDouble(String? formattedString) {
    if (formattedString == null || formattedString.trim().isEmpty) {
      return 0.0;
    }
    // Hapus semua karakter selain angka (digit 0-9)
    final cleanText = formattedString.replaceAll(RegExp(r'[^0-9]'), '');
    return double.tryParse(cleanText) ?? 0.0;
  }
}
