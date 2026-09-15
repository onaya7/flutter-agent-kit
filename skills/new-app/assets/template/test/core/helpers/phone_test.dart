import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kit_template_app/core/helpers/phone_country.dart';
import 'package:kit_template_app/core/helpers/phone_input_formatter.dart';
import 'package:kit_template_app/core/helpers/validators.dart';

void main() {
  const gb = PhoneCountry.gb;

  group('toE164', () {
    test('normalises a national number', () {
      expect(gb.toE164('07123 456789'), '+447123456789');
      expect(gb.toE164('07123456789'), '+447123456789');
    });

    test('accepts a trunk-less number', () {
      expect(gb.toE164('7123456789'), '+447123456789');
    });

    test('accepts the 00 international prefix', () {
      expect(gb.toE164('00447123456789'), '+447123456789');
    });

    test('is idempotent on a number that is already E.164', () {
      expect(gb.toE164('+442919102833'), '+442919102833');
      expect(gb.toE164(gb.toE164('+442919102833')), '+442919102833');
    });

    test('returns empty for empty input', () {
      expect(gb.toE164(''), '');
      expect(gb.toE164('   '), '');
    });

    test('echoes unparseable input rather than dropping it', () {
      expect(gb.toE164('not a number'), 'not a number');
      expect(gb.toE164('12345'), '12345');
    });
  });

  group('toNational', () {
    test('renders E.164 in display form', () {
      expect(gb.toNational('+442919102833'), '02919 102833');
      expect(gb.toNational('+447123456789'), '07123 456789');
    });

    test('round-trips with toE164', () {
      expect(gb.toE164(gb.toNational('+442919102833')), '+442919102833');
    });

    test('echoes input it cannot parse', () {
      expect(gb.toNational('+44 1234'), '+44 1234');
      expect(gb.toNational(''), '');
    });
  });

  group('isValid', () {
    test('accepts mobile and landline', () {
      expect(gb.isValid('07123456789'), isTrue);
      expect(gb.isValid('02012345678'), isTrue);
      expect(gb.isValid('+447123456789'), isTrue);
      expect(gb.isValid('7123456789'), isTrue);
    });

    test('rejects wrong lengths', () {
      expect(gb.isValid('0712345678'), isFalse);
      expect(gb.isValid('071234567890'), isFalse);
    });

    test('rejects a doubled trunk prefix and non-digits', () {
      expect(gb.isValid('007123456789'), isFalse);
      expect(gb.isValid('not a number'), isFalse);
    });
  });

  group('Validators.phone', () {
    test('required by default', () {
      expect(Validators.phone(''), 'Phone number is required');
      expect(Validators.phone(null), 'Phone number is required');
    });

    test('empty passes when optional, malformed still fails', () {
      expect(Validators.phone('', required: false), isNull);
      expect(Validators.phone('   ', required: false), isNull);
      expect(Validators.phone('123', required: false), isNotNull);
    });

    test('accepts a valid number and names the expected shape', () {
      expect(Validators.phone('07123 456789'), isNull);
      expect(Validators.phone('123'), contains(gb.example));
    });
  });

  group('PhoneInputFormatter', () {
    const formatter = PhoneInputFormatter();

    String format(String input) => formatter
        .formatEditUpdate(
          TextEditingValue.empty,
          TextEditingValue(
            text: input,
            selection: TextSelection.collapsed(offset: input.length),
          ),
        )
        .text;

    test('groups a national number as it is typed', () {
      expect(format('07123456789'), '07123 456789');
    });

    test('leaves a partial number alone', () {
      expect(format('0712'), '0712');
      expect(format('07123'), '07123');
    });

    test('converts seeded E.164 to national instead of truncating it', () {
      expect(format('+442919102833'), '02919 102833');
    });

    test('caps at the country max', () {
      expect(format('071234567890123'), '07123 456789');
    });
  });
}
