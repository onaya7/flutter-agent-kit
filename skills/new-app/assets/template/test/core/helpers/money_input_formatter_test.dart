import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kit_template_app/core/helpers/money_input_formatter.dart';

void main() {
  String applied(String input, {int maxDecimals = 2}) {
    return MoneyInputFormatter(maxDecimals: maxDecimals)
        .formatEditUpdate(
          TextEditingValue.empty,
          TextEditingValue(
            text: input,
            selection: TextSelection.collapsed(offset: input.length),
          ),
        )
        .text;
  }

  group('formatEditUpdate', () {
    test('groups thousands', () {
      expect(applied('1234567'), '1,234,567');
    });

    test('keeps a trailing point so decimals can be typed', () {
      expect(applied('1234.'), '1,234.');
    });

    test('promotes a leading point to a zero', () {
      expect(applied('.5'), '0.5');
    });

    test('collapses extra decimal points', () {
      expect(applied('1.2.3'), '1.23');
    });

    test('clamps the fraction to maxDecimals', () {
      expect(applied('9.8765'), '9.87');
      expect(applied('9.8765', maxDecimals: 3), '9.876');
    });

    test('maxDecimals zero keeps only whole units', () {
      expect(applied('1234.56', maxDecimals: 0), '1,234');
    });

    test('strips everything that is not a digit or a point', () {
      expect(applied(r'12a$4'), '124');
    });

    test('an empty field stays empty', () {
      expect(applied(''), '');
      expect(applied('abc'), '');
    });
  });

  group('caret placement', () {
    test('lands after the same digit once separators are inserted', () {
      final value = MoneyInputFormatter().formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(
          text: '1234',
          selection: TextSelection.collapsed(offset: 4),
        ),
      );

      expect(value.text, '1,234');
      expect(value.selection.baseOffset, 5);
    });
  });

  group('round trip', () {
    test('unformat strips the separators', () {
      expect(MoneyInputFormatter.unformat('1,234.50'), '1234.50');
      expect(MoneyInputFormatter.unformat(' 1,234 '), '1234');
    });

    test('format re-groups a raw value', () {
      expect(MoneyInputFormatter.format('1234.5'), '1,234.5');
      expect(MoneyInputFormatter.format('1,234.567'), '1,234.56');
    });
  });
}
