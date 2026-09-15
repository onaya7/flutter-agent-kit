import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kit_template_app/config/theme/app_theme_colors.dart';
import 'package:kit_template_app/core/constants/keys.dart';
import 'package:kit_template_app/core/helpers/ui_helpers.dart';

/// One bottom-navigation tab; [rootName] is its branch's root route name.
@immutable
class NavigationTab {
  const NavigationTab({
    required this.icon,
    required this.label,
    required this.rootName,
  });

  final IconData icon;
  final String label;
  final String rootName;
}

/// Shell hosting the bottom nav: haptics, and pop-to-root on the active tab.
class CustomNavigationBar extends StatelessWidget {
  const CustomNavigationBar({
    required this.navigationShell,
    required this.tabs,
    this.drawer,
    this.showBottomNavigation = true,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  /// One per shell branch, in branch order.
  final List<NavigationTab> tabs;
  final Widget? drawer;
  final bool showBottomNavigation;

  void _goBranch(BuildContext context, int index) {
    unawaited(UiHelpers.hapticFeedback(FeedbackType.selection));
    if (index == navigationShell.currentIndex) {
      UiHelpers.replaceStack(context, tabs[index].rootName);
    } else {
      navigationShell.goBranch(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    return Scaffold(
      key: Keys.shellScaffoldKey,
      drawer: drawer,
      body: navigationShell,
      bottomNavigationBar: showBottomNavigation
          ? DecoratedBox(
              decoration: BoxDecoration(
                color: colors.cards,
                border: Border(top: BorderSide(color: colors.divider)),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      for (var i = 0; i < tabs.length; i++)
                        _NavButton(
                          tab: tabs[i],
                          active: i == navigationShell.currentIndex,
                          onTap: () => _goBranch(context, i),
                        ),
                    ],
                  ),
                ),
              ),
            )
          : null,
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.tab,
    required this.active,
    required this.onTap,
  });

  final NavigationTab tab;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    final color = active ? colors.primary : colors.iconLow;
    return Semantics(
      button: true,
      selected: active,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(tab.icon, size: 24, color: color),
              const SizedBox(height: 4),
              Text(
                tab.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
