# Tabs: `StatefulShellRoute` and the nav bar

Detail for step 5 of `setup-go-router`.


```dart
static StatefulShellRoute _buildMainNavigationRoutes() {
  return StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) => CustomNavigationBar(
      navigationShell: navigationShell,
      // Drawer (and its edge-swipe) only on the Home branch.
      drawer: navigationShell.currentIndex == 0 ? const AppDrawer() : null,
      showBottomNavigation: !_shouldHideBottomNavigation(state),
    ),
    branches: [
      // HOME BRANCH — index 0
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: RoutesPath.home,
            name: RoutesName.home,
            builder: (_, __) => const HomeView(),
            routes: [
              GoRoute(
                path: RoutesPath.services, // relative → /home/services
                name: RoutesName.services,
                pageBuilder: (context, state) => CustomTransitionPage<void>(
                  key: state.pageKey,
                  child: const ServicesView(),
                  transitionsBuilder: _slideUpTransition,
                ),
              ),
            ],
          ),
        ],
      ),
      // One StatefulShellBranch per remaining tab
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: RoutesPath.jobs,
            name: RoutesName.jobs,
            builder: (_, __) => const JobsView(),
          ),
        ],
      ),
    ],
  );
}
```

**Branch order is load-bearing** — it is the tab index. Anything keyed off `currentIndex` (here,
the drawer on index 0) silently moves if you reorder branches. Branches need no `navigatorKey` of
their own.

Hiding the bar on full-screen children of a branch:

```dart
/// Hides the bottom navigation on full-screen detail routes.
static bool _shouldHideBottomNavigation(GoRouterState state) {
  final hideNavRoutePrefixes = <String>[
    '${RoutesPath.home}/${RoutesPath.services}',
    '${RoutesPath.home}/${RoutesPath.notifications}',
  ];
  final currentPath = state.uri.toString();
  return hideNavRoutePrefixes.any(currentPath.startsWith);
}
```

Compose these from the `RoutesPath` consts rather than hardcoding `'/home/services'` — hardcoded
literals leave a stale rule behind when a path is renamed, and nothing fails to compile. Only
branch-nested routes need listing; top-level overlays sit above the shell and never show the bar.

The shell widget owns the `Scaffold`, and re-tapping the active tab pops that branch to its root:

```dart
class CustomNavigationBar extends StatelessWidget {
  const CustomNavigationBar({
    required this.navigationShell,
    this.drawer,
    this.showBottomNavigation = true,
    super.key,
  });

  final StatefulNavigationShell navigationShell;
  final Widget? drawer;
  final bool showBottomNavigation;

  void _goBranch(BuildContext context, int index) {
    if (index == navigationShell.currentIndex) {
      UiHelpers.replaceStack(context, _items[index].rootName); // re-tap → pop to root
    } else {
      navigationShell.goBranch(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: Keys.shellScaffoldKey,
      drawer: drawer,
      body: navigationShell,
      bottomNavigationBar: showBottomNavigation ? _bar(context) : null,
    );
  }
}
```

`goBranch` is the one sanctioned place that touches `StatefulNavigationShell` directly; it does not
go through `UiHelpers`.
