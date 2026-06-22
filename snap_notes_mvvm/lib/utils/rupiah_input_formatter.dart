import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class RupiahInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Jika input dihapus hingga kosong, biarkan kosong
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Hanya ambil digit angka (mencegah minus, huruf, atau tanda baca lain)
    final cleanText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleanText.isEmpty) {
      return newValue.copyWith(
        text: '',
        selection: const TextSelection.collapsed(offset: 0),
      );
    }

    // Parse string bersih ke angka double/int
    final value = double.tryParse(cleanText) ?? 0.0;

    // Format dengan separator ribuan titik (pola 'id_ID')
    final formatter = NumberFormat.decimalPattern('id');
    final formattedText = formatter.format(value);

    // Hitung posisi kursor secara presisi agar tidak melompat ketika ribuan ditambahkan/dikurangi
    int selectionIndex = newValue.selection.end;
    
    int digitsBeforeCursor = 0;
    for (int i = 0; i < selectionIndex && i < newValue.text.length; i++) {
      if (RegExp(r'[0-9]').hasMatch(newValue.text[i])) {
        digitsBeforeCursor++;
      }
    }

    int newSelectionIndex = 0;
    int digitCount = 0;
    while (newSelectionIndex < formattedText.length && digitCount < digitsBeforeCursor) {
      if (RegExp(r'[0-9]').hasMatch(formattedText[newSelectionIndex])) {
        digitCount++;
      }
      newSelectionIndex++;
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: newSelectionIndex),
    );
  }
}
