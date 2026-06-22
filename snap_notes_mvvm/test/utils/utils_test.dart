import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:snap_notes_mvvm/utils/format_utils.dart';
import 'package:snap_notes_mvvm/utils/rupiah_input_formatter.dart';

void main() {
  setUpAll(() async {
    // Inisialisasi data lokalisasi untuk keperluan testing format tanggal
    await initializeDateFormatting('id_ID', null);
  });

  group('FormatUtils Tests', () {
    group('formatRupiah', () {
      test('should format positive integer to standard Rupiah format', () {
        expect(FormatUtils.formatRupiah(1000), 'Rp 1.000');
        expect(FormatUtils.formatRupiah(2500000), 'Rp 2.500.000');
      });

      test('should format double values to nearest integer Rupiah format', () {
        expect(FormatUtils.formatRupiah(12345.67), 'Rp 12.346');
        expect(FormatUtils.formatRupiah(0.0), 'Rp 0');
      });

      test('should handle null value and return Rp 0', () {
        expect(FormatUtils.formatRupiah(null), 'Rp 0');
      });
    });

    group('formatIndonesianDate', () {
      test('should format DateTime to Indonesian date format', () {
        final date = DateTime(2026, 7, 12);
        expect(FormatUtils.formatIndonesianDate(date), '12 Juli 2026');

        final dateNewYear = DateTime(2026, 1, 1);
        expect(FormatUtils.formatIndonesianDate(dateNewYear), '1 Januari 2026');
      });

      test('should handle null date and return strip (-)', () {
        expect(FormatUtils.formatIndonesianDate(null), '-');
      });
    });

    group('parseRupiahToDouble', () {
      test('should parse formatted rupiah string to double', () {
        expect(FormatUtils.parseRupiahToDouble('Rp 12.345'), 12345.0);
        expect(FormatUtils.parseRupiahToDouble('12.345'), 12345.0);
      });

      test('should strip off negative sign and non-numeric characters', () {
        expect(FormatUtils.parseRupiahToDouble('-12.345'), 12345.0);
        expect(FormatUtils.parseRupiahToDouble('Rp -50.000'), 50000.0);
        expect(FormatUtils.parseRupiahToDouble('abc 123 def'), 123.0);
      });

      test('should return 0.0 for empty or null strings', () {
        expect(FormatUtils.parseRupiahToDouble(''), 0.0);
        expect(FormatUtils.parseRupiahToDouble(null), 0.0);
      });
    });
  });

  group('RupiahInputFormatter Tests', () {
    final formatter = RupiahInputFormatter();

    test('should format raw numeric input with thousands separator', () {
      const oldValue = TextEditingValue.empty;
      const newValue = TextEditingValue(
        text: '25000',
        selection: TextSelection.collapsed(offset: 5),
      );

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, '25.000');
      expect(result.selection.end, 6); // 25.000 has length 6, cursor at the end
    });

    test('should ignore negative sign and keep formatting positive', () {
      const oldValue = TextEditingValue.empty;
      const newValue = TextEditingValue(
        text: '-50000',
        selection: TextSelection.collapsed(offset: 6),
      );

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, '50.000');
      expect(result.selection.end, 6);
    });

    test('should handle empty input cleanly', () {
      const oldValue = TextEditingValue.empty;
      const newValue = TextEditingValue.empty;

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, '');
      expect(result.selection.end, -1);
    });

    test('should ignore alphabetical input', () {
      const oldValue = TextEditingValue.empty;
      const newValue = TextEditingValue(
        text: 'abc',
        selection: TextSelection.collapsed(offset: 3),
      );

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, '');
      expect(result.selection.end, 0);
    });

    test('should correctly position the cursor when typing in the middle', () {
      const oldValue = TextEditingValue(
        text: '12.000',
        selection: TextSelection.collapsed(offset: 2), // 12|..
      );
      const newValue = TextEditingValue(
        text: '123.000', // added '3' in the middle -> 123|.000
        selection: TextSelection.collapsed(offset: 3),
      );

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, '123.000');
      expect(result.selection.end, 3); // cursor should stay after '3' -> 123|.000
    });
  });
}
