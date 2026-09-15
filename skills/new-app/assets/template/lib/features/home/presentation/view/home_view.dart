import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:kit_template_app/config/theme/app_theme_colors.dart';
import 'package:kit_template_app/core/components/custom_scaffold.dart';
import 'package:kit_template_app/core/constants/app_size.dart';
import 'package:kit_template_app/l10n/l10n.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = AppThemeColors.of(context);
    return CustomScaffold(
      title: l10n.homeTitle,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colors.iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                IconsaxPlusBold.home_2,
                size: 32,
                color: colors.primary,
              ),
            ),
            AppSize.h(16),
            Text(
              l10n.homeWelcomeTitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.textHeading,
              ),
            ),
            AppSize.h(8),
            Text(
              l10n.homeWelcomeMessage,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: colors.subtext),
            ),
          ],
        ),
      ),
    );
  }
}
