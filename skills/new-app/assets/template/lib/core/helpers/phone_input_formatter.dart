import 'package:flutter/services.dart';
import 'package:kit_template_app/core/helpers/phone_country.dart';

/// Use [PhoneCountry.toE164] to normalise before sending.
class PhoneInputFormatter extends TextInputFormatter {
  const PhoneInputFormatter({this.country = PhoneCountry.fallback});

  final PhoneCountry country;

  static final RegExp _nonDigit = RegExp(r'\D');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final selectionIndex = newValue.selection.end;
    final digitsBeforeCaret = newValue.text
        .substring(0, selectionIndex)
        .replaceAll(_nonDigit, '')
        .length;

    var digits = newValue.text.replaceAll(_nonDigit, '');

    // Without this the '+' is dropped and the dial code eats the mask.
    final national = country.nationalNumber(newValue.text);
    if (national != null) {
      digits = '${country.trunkPrefix}$national';
    } else if (digits.length > country.maxDigits) {
      digits = digits.substring(0, country.maxDigits);
    }

    final formatted = country.format(digits);

    var caret = 0;
    var seen = 0;
    while (caret < formatted.length && seen < digitsBeforeCaret) {
      if (!_nonDigit.hasMatch(formatted[caret])) seen++;
      caret++;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: caret.clamp(0, formatted.length),
      ),
    );
  }
}
