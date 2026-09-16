import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kit_template_app/config/theme/app_theme_colors.dart';
import 'package:kit_template_app/core/constants/app_color.dart';
import 'package:kit_template_app/core/helpers/ui_helpers.dart';

/// Compact switch with a white thumb; the track turns [activeColor] when on.
class AppSwitch extends StatelessWidget {
  const AppSwitch({
    required this.value,
    required this.onChanged,
    this.activeColor,
    super.key,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    return SizedBox(
      height: 28,
      child: FittedBox(
        fit: BoxFit.fill,
        child: Switch(
          value: value,
          onChanged: (v) {
            unawaited(UiHelpers.hapticFeedback(FeedbackType.selection));
            onChanged(v);
          },
          activeThumbColor: AppColor.white,
          activeTrackColor: activeColor ?? colors.primary,
          inactiveThumbColor: AppColor.white,
          inactiveTrackColor: colors.fill,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}
