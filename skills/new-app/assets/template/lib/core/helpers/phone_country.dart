import 'dart:math' as math;

import 'package:flutter/foundation.dart';

final RegExp _nonDigit = RegExp(r'\D');

/// Another country is a new const plus a [supported] entry; no branching.
@immutable
class PhoneCountry {
  const PhoneCountry({
    required this.isoCode,
    required this.dialCode,
    required this.flag,
    required this.trunkPrefix,
    required this.nsnLengths,
    required this.grouping,
    required this.example,
  });

  /// ISO 3166-1 alpha-2.
  final String isoCode;

  /// Calling code including the `+`.
  final String dialCode;
  final String flag;

  /// Dropped when building E.164, restored for display.
  final String trunkPrefix;

  /// Accepted national significant number lengths.
  final Set<int> nsnLengths;

  /// Digit-group sizes for the display mask, trunk prefix included.
  final List<int> grouping;

  /// Used in hint and error copy.
  final String example;

  static const gb = PhoneCountry(
    isoCode: 'GB',
    dialCode: '+44',
    flag: '🇬🇧',
    trunkPrefix: '0',
    // 10 digits covers both mobile (07…) and landline (01/02…).
    nsnLengths: {10},
    grouping: [5, 6],
    example: '07123 456789',
  );

  static const supported = <PhoneCountry>[gb];

  /// Used wherever country selection isn't offered yet.
  static const PhoneCountry fallback = gb;

  static PhoneCountry? fromIso(String? iso) {
    if (iso == null) return null;
    final upper = iso.toUpperCase();
    for (final country in supported) {
      if (country.isoCode == upper) return country;
    }
    return null;
  }

  /// Longest dial-code match first, so `+1` and `+1242` stay distinct.
  static PhoneCountry? fromDialCode(String value) {
    final digits = value.replaceAll(_nonDigit, '');
    PhoneCountry? best;
    var bestLength = 0;
    for (final country in supported) {
      final code = country._bareDialCode;
      if (digits.startsWith(code) && code.length > bestLength) {
        best = country;
        bestLength = code.length;
      }
    }
    return best;
  }

  /// Trunk prefix plus the longest national number.
  int get maxDigits => trunkPrefix.length + nsnLengths.reduce(math.max);

  String get _bareDialCode => dialCode.replaceAll(_nonDigit, '');

  /// The dial code is stripped *before* the trunk prefix, never after.
  String? nationalNumber(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;

    var digits = trimmed.replaceAll(_nonDigit, '');
    if (digits.isEmpty) return null;

    final code = _bareDialCode;
    if (trimmed.startsWith('+') && digits.startsWith(code)) {
      digits = digits.substring(code.length);
    } else if (digits.startsWith('00$code')) {
      digits = digits.substring(2 + code.length);
    } else if (digits.startsWith(code) && digits.length > maxDigits) {
      // No '+', but too long to be national: read the lead as the dial code.
      digits = digits.substring(code.length);
    }

    if (trunkPrefix.isNotEmpty && digits.startsWith(trunkPrefix)) {
      digits = digits.substring(trunkPrefix.length);
    }

    // A remaining leading zero means a doubled trunk prefix, not a number.
    if (digits.startsWith('0')) return null;
    return nsnLengths.contains(digits.length) ? digits : null;
  }

  bool isValid(String input) => nationalNumber(input) != null;

  /// Unparseable input is echoed back rather than dropped.
  String toE164(String input) {
    final national = nationalNumber(input);
    if (national != null) return '$dialCode$national';
    return input.trim();
  }

  /// Unparseable input is echoed back so an oddity stays editable.
  String toNational(String input) {
    final national = nationalNumber(input);
    if (national == null) return input.trim();
    return format('$trunkPrefix$national');
  }

  /// Groups bare digits per [grouping]; trailing digits form a final group.
  String format(String digits) {
    final parts = <String>[];
    var index = 0;
    for (final size in grouping) {
      if (index >= digits.length) break;
      parts.add(digits.substring(index, math.min(index + size, digits.length)));
      index += size;
    }
    if (index < digits.length) parts.add(digits.substring(index));
    return parts.join(' ');
  }
}
