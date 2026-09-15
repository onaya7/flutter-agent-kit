# Home

## Purpose
The welcome screen on the first tab. It is a presentation-only example feature and the natural
place to start building the app's real home screen.

## Entry screens
- `HomeView` (`lib/features/home/presentation/view/home_view.dart`) at `RoutesName.home` /
  `RoutesPath.home` (`/home`), the root route of the first shell branch.
- It is the router's `initialLocation` and the target of `NotFoundView`'s "Go home" action.

## Endpoints
None.

## State
No bloc or cubit. The view reads only `AppThemeColors` and `context.l10n`.

## Key files
- `lib/features/home/presentation/view/home_view.dart`
- `lib/config/navigators/routes_generator.dart`
- `lib/core/components/custom_navigationbar.dart`
- `lib/l10n/arb/app_en.arb`

## Gotchas
- The tab's icon and label come from the `NavigationTab` list in `routes_generator.dart`, not from
  this feature.
- `RoutesPath.home` is also the router's initial location, so renaming it changes where the app
  opens.
