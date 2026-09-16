import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kit_template_app/config/theme/app_theme_colors.dart';
import 'package:kit_template_app/core/components/radio_dot.dart';
import 'package:kit_template_app/core/constants/app_size.dart';
import 'package:kit_template_app/core/helpers/ui_helpers.dart';

/// A tappable radio dot with a trailing label.
class RadioOption extends StatelessWidget {
  const RadioOption({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        unawaited(UiHelpers.hapticFeedback(FeedbackType.selection));
        onTap();
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          RadioDot(selected: selected),
          AppSize.w(4),
          Text(
            label,
            style: TextStyle(color: colors.textHeading, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
