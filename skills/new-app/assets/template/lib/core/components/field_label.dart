import 'package:flutter/material.dart';
import 'package:kit_template_app/config/theme/app_theme_colors.dart';

/// Label above a form field or section — one heading-coloured [Text].
class FieldLabel extends StatelessWidget {
  const FieldLabel(
    this.text, {
    this.fontSize = 16,
    this.fontWeight = FontWeight.w500,
    super.key,
  });

  final String text;
  final double fontSize;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: AppThemeColors.of(context).textHeading,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
    );
  }
}
