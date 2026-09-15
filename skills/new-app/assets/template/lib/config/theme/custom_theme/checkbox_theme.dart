import 'package:flutter/material.dart';
import 'package:kit_template_app/config/theme/app_theme_colors.dart';

/// Fill follows `primary`; disabled follows `iconInactive`.
class TCheckBoxTheme {
  TCheckBoxTheme._();

  static CheckboxThemeData _theme({
    required Color fill,
    required Color check,
    required Color disabled,
  }) => CheckboxThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
    checkColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) return disabled;
      return check;
    }),
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) return disabled;
      if (states.contains(WidgetState.selected)) return fill;
      return Colors.transparent;
    }),
    overlayColor: WidgetStateProperty.all(disabled),
    splashRadius: 20,
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );

  static CheckboxThemeData lightCheckBoxTheme = _theme(
    fill: AppThemeColors.light.primary,
    check: AppThemeColors.light.cards,
    disabled: AppThemeColors.light.iconInactive,
  );

  // The dark primary is light, so the tick takes the dark surface.
  static CheckboxThemeData darkCheckBoxTheme = _theme(
    fill: AppThemeColors.dark.primary,
    check: AppThemeColors.dark.background,
    disabled: AppThemeColors.dark.iconInactive,
  );
}
