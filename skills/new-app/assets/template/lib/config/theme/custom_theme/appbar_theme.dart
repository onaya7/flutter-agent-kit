import 'package:flutter/material.dart';
import 'package:kit_template_app/config/theme/app_theme_colors.dart';

/// `ThemeData` is built without a context, so these read the role constants.
class TAppBarTheme {
  TAppBarTheme._();

  static AppBarTheme lightAppBarTheme = _theme(AppThemeColors.light);

  static AppBarTheme darkAppBarTheme = _theme(AppThemeColors.dark);

  static AppBarTheme _theme(AppThemeColors colors) => AppBarTheme(
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 0,
    backgroundColor: colors.background,
    surfaceTintColor: colors.background,
    iconTheme: IconThemeData(color: colors.icon),
    actionsIconTheme: IconThemeData(color: colors.icon),
    titleTextStyle: TextStyle(
      color: colors.textHeading,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
  );
}
