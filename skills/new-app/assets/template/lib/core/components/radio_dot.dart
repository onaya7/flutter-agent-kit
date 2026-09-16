import 'package:flutter/material.dart';
import 'package:kit_template_app/config/theme/app_theme_colors.dart';
import 'package:kit_template_app/core/constants/app_color.dart';

/// The dot half of a radio control, without a label or a tap target.
class RadioDot extends StatelessWidget {
  const RadioDot({required this.selected, super.key});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    if (!selected) {
      return Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: colors.fill, width: 1.5),
        ),
      );
    }
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: colors.primary,
        shape: BoxShape.circle,
        border: Border.all(color: colors.primary, width: 1.5),
      ),
      child: const Center(
        child: SizedBox.square(
          dimension: 8,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColor.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
