import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Digits and one decimal point; use [unformat] before sending.
class MoneyInputFormatter extends TextInputFormatter {
  MoneyInputFormatter({this.maxDecimals = 2});

  final int maxDecimals;

  static final NumberFormat _grouping = NumberFormat.decimalPattern('en');
  static final RegExp _valueChar = RegExp('[0-9.]');

  /// `"1,234.50"` → `"1234.50"`.
  static String unformat(String text) => text.replaceAll(',', '').trim();

  /// Formats a raw numeric string for display (`"1234.5"` → `"1,234.5"`).
  static String format(String raw, {int maxDecimals = 2}) =>
      _formatNumeric(raw.replaceAll(',', ''), maxDecimals);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Counted so the caret lands at the same logical spot after grouping.
    final selectionIndex = newValue.selection.end;
    final valueCharsBeforeCaret = _valueChar
        .allMatches(newValue.text.substring(0, selectionIndex))
        .length;

    final formatted = _formatNumeric(newValue.text, maxDecimals);

    var caret = 0;
    var seen = 0;
    while (caret < formatted.length && seen < valueCharsBeforeCaret) {
      if (_valueChar.hasMatch(formatted[caret])) seen++;
      caret++;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: caret),
    );
  }

  static String _formatNumeric(String input, int maxDecimals) {
    // Keep only digits and dots, then collapse to a single decimal point.
    var cleaned = input.replaceAll(RegExp('[^0-9.]'), '');
    final firstDot = cleaned.indexOf('.');
    if (firstDot != -1) {
      cleaned =
          cleaned.substring(0, firstDot + 1) +
          cleaned.substring(firstDot + 1).replaceAll('.', '');
    }
    if (cleaned.isEmpty) return '';

    final hasDot = cleaned.contains('.');
    var intPart = hasDot ? cleaned.substring(0, cleaned.indexOf('.')) : cleaned;
    var fracPart = hasDot ? cleaned.substring(cleaned.indexOf('.') + 1) : '';

    // ".5" → "0.5"; clamp the fraction to maxDecimals.
    if (intPart.isEmpty) intPart = '0';
    if (fracPart.length > maxDecimals) {
      fracPart = fracPart.substring(0, maxDecimals);
    }

    final grouped = _grouping.format(int.parse(intPart));
    if (!hasDot) return grouped;
    // Preserve a trailing dot so the user can keep typing the decimals.
    return maxDecimals == 0 ? grouped : '$grouped.$fracPart';
  }
}
