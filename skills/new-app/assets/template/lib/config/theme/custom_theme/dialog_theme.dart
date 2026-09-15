import 'package:flutter/material.dart';
import 'package:kit_template_app/config/theme/app_theme_colors.dart';

/// Surface follows `cards`, title `textHeading`, body `iconLow`.
class TDialogTheme {
  TDialogTheme._();

  static DialogThemeData _theme(AppThemeColors colors) => DialogThemeData(
    backgroundColor: colors.cards,
    surfaceTintColor: colors.cards,
    elevation: 0,
    insetPadding: const EdgeInsets.symmetric(horizontal: 24),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    titleTextStyle: TextStyle(
      color: colors.textHeading,
      fontSize: 17,
      fontWeight: FontWeight.w500,
    ),
    contentTextStyle: TextStyle(
      color: colors.iconLow,
      fontSize: 14,
      height: 1.5,
    ),
  );

  static final DialogThemeData lightDialogTheme = _theme(AppThemeColors.light);

  static final DialogThemeData darkDialogTheme = _theme(AppThemeColors.dark);
}
