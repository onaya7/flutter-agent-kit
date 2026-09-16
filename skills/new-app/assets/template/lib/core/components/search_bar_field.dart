import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:kit_template_app/config/theme/app_theme_colors.dart';

/// A rounded search pill that opens a search screen; it takes no input itself.
class SearchBarField extends StatelessWidget {
  const SearchBarField({required this.onTap, this.hint = 'Search', super.key});

  final VoidCallback onTap;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 11),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: colors.stroke),
        ),
        child: Row(
          children: [
            Icon(
              IconsaxPlusLinear.search_normal,
              size: 20,
              color: colors.subtext,
            ),
            const SizedBox(width: 7),
            Text(
              hint,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colors.subtext,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
