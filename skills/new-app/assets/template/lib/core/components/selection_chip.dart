import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kit_template_app/config/theme/app_theme_colors.dart';
import 'package:kit_template_app/core/components/custom_ripple.dart';
import 'package:kit_template_app/core/helpers/ui_helpers.dart';

/// Outlined chip that toggles between selected and unselected.
class SelectionChip extends StatelessWidget {
  const SelectionChip({
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
    return CustomRipple(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        unawaited(UiHelpers.hapticFeedback(FeedbackType.selection));
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? colors.primary : colors.stroke,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? colors.primary : colors.textHeading,
            fontSize: 14,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

/// Chip standing for an already-made choice, with a trailing remove button.
class RemovableChip extends StatelessWidget {
  const RemovableChip({required this.label, required this.onRemove, super.key});

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 8, 10, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.stroke),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: colors.textHeading,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () {
              unawaited(UiHelpers.hapticFeedback(FeedbackType.light));
              onRemove();
            },
            child: Icon(Icons.close_rounded, size: 16, color: colors.iconLow),
          ),
        ],
      ),
    );
  }
}
