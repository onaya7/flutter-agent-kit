import 'package:flutter/material.dart';
import 'package:kit_template_app/config/theme/app_theme_colors.dart';
import 'package:kit_template_app/core/constants/app_color.dart';

/// Borders follow `stroke` and the hint follows `subtext`, so fields adapt.
class TInputDecorationTheme {
  TInputDecorationTheme._();

  static const _radius = 30.0;
  static const _padding = EdgeInsets.symmetric(vertical: 14, horizontal: 20);

  static InputDecorationTheme _theme(AppThemeColors colors) =>
      InputDecorationTheme(
        filled: false,
        hintStyle: TextStyle(
          color: colors.subtext,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.never,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colors.stroke),
          borderRadius: BorderRadius.circular(_radius),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colors.stroke),
          borderRadius: BorderRadius.circular(_radius),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colors.primary, width: 1.5),
          borderRadius: BorderRadius.circular(_radius),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColor.error),
          borderRadius: BorderRadius.circular(_radius),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColor.error, width: 1.5),
          borderRadius: BorderRadius.circular(_radius),
        ),
        contentPadding: _padding,
      );

  static final InputDecorationTheme inputDecorationThemeLight = _theme(
    AppThemeColors.light,
  );

  static final InputDecorationTheme inputDecorationThemeDark = _theme(
    AppThemeColors.dark,
  );
}
