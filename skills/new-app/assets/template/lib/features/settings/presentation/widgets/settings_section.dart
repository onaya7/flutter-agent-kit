import 'package:flutter/material.dart';
import 'package:kit_template_app/config/theme/app_theme_colors.dart';
import 'package:kit_template_app/core/constants/app_size.dart';

/// A labelled settings group: a caption above a full-width control.
class SettingsSection extends StatelessWidget {
  const SettingsSection({required this.label, required this.child, super.key});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colors.subtext,
          ),
        ),
        AppSize.h(8),
        SizedBox(width: double.infinity, child: child),
      ],
    );
  }
}
