import 'package:flutter/material.dart';
import 'package:kit_template_app/config/theme/app_theme_colors.dart';

/// Track follows `strokeFill` and thumb follows `iconInactive`.
class TScrollBarTheme {
  TScrollBarTheme._();

  static ScrollbarThemeData _theme(AppThemeColors colors) => ScrollbarThemeData(
    thumbVisibility: WidgetStateProperty.all(true),
    trackVisibility: WidgetStateProperty.all(true),
    trackColor: WidgetStateProperty.all(colors.strokeFill),
    thumbColor: WidgetStateProperty.all(colors.iconInactive),
    thickness: WidgetStateProperty.all(4),
    radius: const Radius.circular(15),
    crossAxisMargin: 8,
    mainAxisMargin: 8,
  );

  static ScrollbarThemeData lightScrollBarTheme = _theme(AppThemeColors.light);

  static ScrollbarThemeData darkScrollBarTheme = _theme(AppThemeColors.dark);
}
