import 'package:flutter/material.dart';
import 'package:kit_template_app/config/theme/app_theme_colors.dart';
import 'package:kit_template_app/core/constants/app_color.dart';

/// Filter chip carrying a count badge, used above a filtered list.
class CountFilterChip extends StatelessWidget {
  const CountFilterChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
    this.countGradient,
    super.key,
  });

  final String label;
  final int? count;
  final bool selected;
  final VoidCallback onTap;

  /// Paints the count with a gradient instead of a flat colour.
  final Gradient? countGradient;

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? colors.primary : colors.cards,
          borderRadius: BorderRadius.circular(21),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: selected ? AppColor.white : colors.textHeading,
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 6),
              _Count(
                count: count!,
                gradient: countGradient,
                color: selected ? AppColor.white : colors.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Count extends StatelessWidget {
  const _Count({
    required this.count,
    required this.gradient,
    required this.color,
  });

  final int count;
  final Gradient? gradient;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final grad = gradient;
    final text = Text(
      '$count',
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        // A ShaderMask paints over the glyphs; the base just has to be opaque.
        color: grad == null ? color : AppColor.white,
      ),
    );
    if (grad == null) return text;
    return ShaderMask(shaderCallback: grad.createShader, child: text);
  }
}
