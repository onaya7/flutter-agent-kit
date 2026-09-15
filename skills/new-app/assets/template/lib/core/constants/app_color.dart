import 'package:flutter/material.dart';

/// Raw primitives; semantic roles live on `AppThemeColors` — prefer those.
abstract class AppColor {
  static const Color primary = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFFA5B4FC);

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFD97706);
  static const Color error = Color(0xFFDC2626);
  static const Color info = Color(0xFF0284C7);

  static const Color scrim = Color(0x66000000);
  static const Color white10 = Color(0x1AFFFFFF);
  static const Color white90 = Color(0xE6FFFFFF);
  static const Color black10 = Color(0x1A000000);
  static const Color black90 = Color(0xE6000000);

  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF4F4F5);
  static const Color grey200 = Color(0xFFE4E4E7);
  static const Color grey300 = Color(0xFFD4D4D8);
  static const Color grey400 = Color(0xFFA1A1AA);
  static const Color grey500 = Color(0xFF71717A);
  static const Color grey600 = Color(0xFF52525B);
  static const Color grey700 = Color(0xFF3F3F46);
  static const Color grey800 = Color(0xFF27272A);
  static const Color grey900 = Color(0xFF18181B);
  static const Color grey950 = Color(0xFF09090B);
}
