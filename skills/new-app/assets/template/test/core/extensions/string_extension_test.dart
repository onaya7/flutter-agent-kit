import 'package:flutter_test/flutter_test.dart';
import 'package:kit_template_app/core/extensions/string_extension.dart';

void main() {
  group('StringAddressX.cleanAddress', () {
    test('drops empty segments padded into an address', () {
      expect(
        '61-71 Victoria Street, , , London, SW1H 0HW, United Kingdom'
            .cleanAddress,
        '61-71 Victoria Street, London, SW1H 0HW, United Kingdom',
      );
    });

    test('handles a leading empty segment', () {
      expect(', , London Road, Royston'.cleanAddress, 'London Road, Royston');
    });

    test('leaves an already-clean address unchanged', () {
      expect(
        'Flat 101, 233 Willesden Lane, London'.cleanAddress,
        'Flat 101, 233 Willesden Lane, London',
      );
    });

    test('trims surrounding whitespace on each part', () {
      expect('  A ,   B  ,C '.cleanAddress, 'A, B, C');
    });

    test('collapses an all-empty address to an empty string', () {
      expect(', , ,'.cleanAddress, '');
      expect(''.cleanAddress, '');
    });
  });

  group('StringCasingX.capitalizeFirst', () {
    test('uppercases only the first character', () {
      expect('barber'.capitalizeFirst, 'Barber');
      expect('mario brown'.capitalizeFirst, 'Mario brown');
    });

    test('leaves an empty string alone', () {
      expect(''.capitalizeFirst, '');
    });
  });

  group('humanizeEnumLabel', () {
    test('title-cases each underscore-separated word', () {
      expect(humanizeEnumLabel('BUSINESS_PARTNER'), 'Business Partner');
      expect(humanizeEnumLabel('MONTHLY'), 'Monthly');
    });

    test('ignores doubled and trailing underscores', () {
      expect(humanizeEnumLabel('A__B_'), 'A B');
    });
  });

  group('NullableStringX.orDash', () {
    test('renders a missing value as an em dash', () {
      const String? missing = null;
      expect(missing.orDash, '—');
      expect(''.orDash, '—');
      expect('   '.orDash, '—');
    });

    test('returns a present value trimmed', () {
      expect('  Ada  '.orDash, 'Ada');
    });
  });

  group('NullableStringX.isBlank', () {
    test('is true for null, empty and whitespace-only values', () {
      const String? missing = null;
      expect(missing.isBlank, isTrue);
      expect(''.isBlank, isTrue);
      expect(' \t\n'.isBlank, isTrue);
    });

    test('is false for a value with content', () {
      expect(' a '.isBlank, isFalse);
    });
  });
}
