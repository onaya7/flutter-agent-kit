extension StringCasingX on String {
  /// Uppercases the first character, leaving the rest unchanged.
  String get capitalizeFirst =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}

/// `BUSINESS_PARTNER` → `Business Partner`, `MONTHLY` → `Monthly`.
String humanizeEnumLabel(String raw) => raw
    .split('_')
    .where((w) => w.isNotEmpty)
    .map((w) => '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
    .join(' ');

extension StringAddressX on String {
  /// Drops the empty segments some APIs pad comma-joined addresses with.
  String get cleanAddress => split(
    ',',
  ).map((part) => part.trim()).where((part) => part.isNotEmpty).join(', ');
}

extension NullableStringX on String? {
  /// An em dash for a missing value, so no placeholder is mistaken for data.
  String get orDash {
    final value = this?.trim();
    return (value == null || value.isEmpty) ? '—' : value;
  }

  /// True for null, empty and whitespace-only values alike.
  bool get isBlank {
    final value = this?.trim();
    return value == null || value.isEmpty;
  }
}
