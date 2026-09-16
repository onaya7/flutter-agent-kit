import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kit_template_app/config/theme/app_theme_colors.dart';
import 'package:kit_template_app/core/components/custom_ripple.dart';
import 'package:kit_template_app/core/constants/app_size.dart';
import 'package:kit_template_app/core/helpers/ui_helpers.dart';

/// Rounded pill that shows a value or placeholder and opens a picker on tap.
class PickerLauncher extends StatelessWidget {
  const PickerLauncher({
    required this.value,
    required this.placeholder,
    required this.onTap,
    this.leading,
    this.trailing,
    super.key,
  });

  final String? value;
  final String placeholder;
  final VoidCallback onTap;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    final hasValue = value != null;
    return CustomRipple(
      borderRadius: BorderRadius.circular(100),
      onTap: () {
        unawaited(UiHelpers.hapticFeedback(FeedbackType.selection));
        onTap();
      },
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: colors.cardFill,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: colors.stroke),
        ),
        child: Row(
          children: [
            if (leading != null) ...[leading!, AppSize.w(8)],
            Expanded(
              child: Text(
                hasValue ? value! : placeholder,
                style: TextStyle(
                  color: hasValue ? colors.textHeading : colors.subtext,
                  fontSize: 14,
                  fontWeight: hasValue ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}
