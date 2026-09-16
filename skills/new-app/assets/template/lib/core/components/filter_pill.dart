import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kit_template_app/config/theme/app_theme_colors.dart';
import 'package:kit_template_app/core/helpers/ui_helpers.dart';

/// Small outlined filter pill beside a search field; icon-only is round.
class FilterPill extends StatelessWidget {
  const FilterPill({
    required this.icon,
    this.label,
    this.onTap,
    this.iconSize = 16,
    this.size = 40,
    super.key,
  });

  final IconData icon;
  final String? label;
  final VoidCallback? onTap;
  final double iconSize;

  /// Height of the pill, and its width too when it is icon-only.
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    final iconOnly = label == null;
    final tap = onTap;
    return GestureDetector(
      onTap: tap == null
          ? null
          : () {
              unawaited(UiHelpers.hapticFeedback(FeedbackType.selection));
              tap();
            },
      child: Container(
        height: size,
        width: iconOnly ? size : null,
        alignment: Alignment.center,
        padding: iconOnly ? null : const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: colors.stroke),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: iconSize, color: colors.subtext),
            if (!iconOnly) ...[
              const SizedBox(width: 6),
              Text(
                label!,
                style: TextStyle(
                  fontSize: 14,
                  color: colors.subtext,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
