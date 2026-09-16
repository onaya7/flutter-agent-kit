import 'package:flutter/material.dart';
import 'package:kit_template_app/config/theme/app_theme_colors.dart';

/// Grab handle; place it first *inside* the sheet, not over the scrim.
class SheetHandle extends StatelessWidget {
  const SheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 5,
        decoration: BoxDecoration(
          color: AppThemeColors.of(context).fill,
          borderRadius: BorderRadius.circular(9),
        ),
      ),
    );
  }
}
