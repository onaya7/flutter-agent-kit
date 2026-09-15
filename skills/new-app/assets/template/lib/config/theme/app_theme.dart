import 'package:flutter/material.dart';
import 'package:kit_template_app/config/theme/app_theme_colors.dart';
import 'package:kit_template_app/config/theme/custom_theme/appbar_theme.dart';
import 'package:kit_template_app/config/theme/custom_theme/checkbox_theme.dart';
import 'package:kit_template_app/config/theme/custom_theme/dialog_theme.dart';
import 'package:kit_template_app/config/theme/custom_theme/input_theme.dart';
import 'package:kit_template_app/config/theme/custom_theme/scrollbar_theme.dart';
import 'package:kit_template_app/config/theme/custom_theme/text_theme.dart';
import 'package:kit_template_app/core/constants/app_color.dart';
import 'package:kit_template_app/gen/fonts.gen.dart';

abstract class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColor.primary),
    fontFamily: FontFamily.inter,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    scrollbarTheme: TScrollBarTheme.lightScrollBarTheme,
    checkboxTheme: TCheckBoxTheme.lightCheckBoxTheme,
    appBarTheme: TAppBarTheme.lightAppBarTheme,
    dialogTheme: TDialogTheme.lightDialogTheme,
    inputDecorationTheme: TInputDecorationTheme.inputDecorationThemeLight,
    textTheme: TTextTheme.lightTextTheme,
    scaffoldBackgroundColor: AppThemeColors.light.background,
    extensions: const [AppThemeColors.light],
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColor.primary,
      brightness: Brightness.dark,
    ),
    fontFamily: FontFamily.inter,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    scrollbarTheme: TScrollBarTheme.darkScrollBarTheme,
    checkboxTheme: TCheckBoxTheme.darkCheckBoxTheme,
    appBarTheme: TAppBarTheme.darkAppBarTheme,
    dialogTheme: TDialogTheme.darkDialogTheme,
    inputDecorationTheme: TInputDecorationTheme.inputDecorationThemeDark,
    textTheme: TTextTheme.darkTextTheme,
    scaffoldBackgroundColor: AppThemeColors.dark.background,
    extensions: const [AppThemeColors.dark],
  );
}
