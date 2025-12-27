import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  static double parseAmount(String input) {
    if (input.isEmpty) return 0.0;
    return double.tryParse(input.replaceAll(',', '')) ?? 0.0;
  }

  static String formatAmount(double amount) {
    final formatter = NumberFormat('#,##0', 'en_US');
    return formatter.format(amount);
  }

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Handle deletion
    if (oldValue.text.length > newValue.text.length) {
      // If deleting a comma, we might need special handling, but standard backspace usually works fine
      // with the logic below effectively re-formatting the remaining number.
    }

    // Remove non-digits to get raw value
    String cleanText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanText.isEmpty) {
      return newValue.copyWith(text: '');
    }

    double value = double.parse(cleanText);
    final formatter = NumberFormat('#,##0', 'en_US');
    String newText = formatter.format(value);

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
