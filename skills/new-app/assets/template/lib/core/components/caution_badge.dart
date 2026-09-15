import 'package:flutter/material.dart';
import 'package:kit_template_app/core/constants/app_color.dart';
import 'package:kit_template_app/gen/assets.gen.dart';

/// Caution/error badge: an exclamation-circle glyph on a tinted halo.
class CautionBadge extends StatelessWidget {
  const CautionBadge({required this.color, this.size = 56, super.key});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) =>
      _IconBadge(color: color, glyph: Assets.icons.alertCircle, size: size);
}

/// Success badge: a check-circle glyph on a tinted halo.
class SuccessBadge extends StatelessWidget {
  const SuccessBadge({
    this.color = AppColor.success,
    this.size = 56,
    super.key,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) =>
      _IconBadge(color: color, glyph: Assets.icons.checkCircle, size: size);
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({
    required this.color,
    required this.glyph,
    required this.size,
  });

  final Color color;
  final SvgGenImage glyph;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.1),
        border: Border.all(
          color: AppColor.white.withValues(alpha: 0.4),
          width: size * 10 / 56,
        ),
      ),
      child: glyph.svg(
        width: size / 2,
        height: size / 2,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      ),
    );
  }
}
