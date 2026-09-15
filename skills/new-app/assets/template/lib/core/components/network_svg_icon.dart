import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kit_template_app/config/theme/app_theme_colors.dart';

/// Square SVG from a URL; image widgets that decode to bitmaps cannot read SVG.
class NetworkSvgIcon extends StatelessWidget {
  const NetworkSvgIcon({
    required this.url,
    required this.fallbackIcon,
    super.key,
    this.size = 24,
    this.color,
  });

  final String? url;
  final IconData fallbackIcon;
  final double size;

  /// Flattens the artwork to one colour; a black glyph dies in dark mode.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final source = url;
    final tint = color ?? AppThemeColors.of(context).icon;
    if (source == null || source.isEmpty) return _fallback(tint);

    return SvgPicture.network(
      source,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(tint, BlendMode.srcIn),
      // Holds the footprint so the row doesn't reflow when the icon lands.
      placeholderBuilder: (_) => SizedBox.square(dimension: size),
      errorBuilder: (_, _, _) => _fallback(tint),
    );
  }

  Widget _fallback(Color tint) => Icon(fallbackIcon, size: size, color: tint);
}
