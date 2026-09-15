import 'package:dio_request_inspector/dio_request_inspector.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:kit_template_app/config/flavor/flavor_config.dart';
import 'package:kit_template_app/config/navigators/app_extra_codec.dart';
import 'package:kit_template_app/config/navigators/routes_names.dart';
import 'package:kit_template_app/config/navigators/routes_path.dart';
import 'package:kit_template_app/core/components/custom_navigationbar.dart';
import 'package:kit_template_app/core/components/not_found_view.dart';
import 'package:kit_template_app/core/constants/keys.dart';
import 'package:kit_template_app/features/home/presentation/view/home_view.dart';
import 'package:kit_template_app/features/settings/presentation/view/settings_view.dart';
import 'package:kit_template_app/l10n/l10n.dart';

class AppRouter {
  AppRouter._();

  static GoRouter create(FlavorConfig config) {
    return GoRouter(
      navigatorKey: Keys.navigatorKey,
      extraCodec: const AppExtraCodec(),
      // Lets the request inspector push its dashboard onto the root.
      observers: config.isProd
          ? const []
          : [DioRequestInspector.navigatorObserver],
      initialLocation: RoutesPath.home,
      debugLogDiagnostics: !config.isProd,
      routes: [_buildMainNavigationRoutes()],
      errorBuilder: (_, _) => const NotFoundView(),
    );
  }

  static StatefulShellRoute _buildMainNavigationRoutes() {
    return StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => CustomNavigationBar(
        navigationShell: navigationShell,
        showBottomNavigation: !_shouldHideBottomNavigation(state),
        tabs: [
          NavigationTab(
            icon: IconsaxPlusBold.home_2,
            label: context.l10n.navHome,
            rootName: RoutesName.home,
          ),
          NavigationTab(
            icon: IconsaxPlusBold.setting_2,
            label: context.l10n.navSettings,
            rootName: RoutesName.settings,
          ),
        ],
      ),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RoutesPath.home,
              name: RoutesName.home,
              builder: (_, _) => const HomeView(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RoutesPath.settings,
              name: RoutesName.settings,
              builder: (_, _) => const SettingsView(),
            ),
          ],
        ),
      ],
    );
  }

  static bool _shouldHideBottomNavigation(GoRouterState state) {
    const hideNavRoutePrefixes = <String>[];
    final currentPath = state.uri.toString();
    return hideNavRoutePrefixes.any(currentPath.startsWith);
  }
}

/// Bottom-to-top slide for full-page overlays; pass it as `transitionsBuilder`.
Widget slideUpTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  final position = Tween(
    begin: const Offset(0, 1),
    end: Offset.zero,
  ).chain(CurveTween(curve: Curves.easeOutCubic)).animate(animation);
  return SlideTransition(position: position, child: child);
}
