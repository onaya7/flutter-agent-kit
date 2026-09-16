import 'package:flutter/material.dart';
import 'package:kit_template_app/config/theme/app_theme_colors.dart';
import 'package:kit_template_app/core/components/custom_cachedimage.dart';
import 'package:kit_template_app/core/constants/app_color.dart';

/// Circular avatar falling back to initials on the primary colour.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    required this.name,
    this.imageUrl = '',
    this.radius = 20,
    super.key,
  });

  final String name;
  final String imageUrl;
  final double radius;

  String get _initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    final initials = _initials;

    final fallback = CircleAvatar(
      radius: radius,
      backgroundColor: colors.primary,
      child: initials.isEmpty
          ? Icon(
              Icons.person_outline_rounded,
              color: AppColor.white,
              size: radius,
            )
          : Text(
              initials,
              style: TextStyle(
                color: AppColor.white,
                fontWeight: FontWeight.w600,
                fontSize: radius * 0.7,
              ),
            ),
    );

    if (imageUrl.isEmpty) return fallback;

    return CustomCachedImage.circular(
      imageUrl: imageUrl,
      radius: radius,
      placeholder: fallback,
      errorWidget: fallback,
    );
  }
}
