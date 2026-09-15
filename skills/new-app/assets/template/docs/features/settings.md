# Settings

## Purpose
Lets the user pick the theme mode (system, light or dark) and the language (English or Spanish).
It is a presentation-only example feature that drives the app-wide `AppBloc`.

## Entry screens
- `SettingsView` (`lib/features/settings/presentation/view/settings_view.dart`) at
  `RoutesName.settings` / `RoutesPath.settings` (`/settings`), the root route of the second shell
  branch.

## Endpoints
None.

## State
- No cubit of its own. The view reads `AppBloc` and dispatches `AppEvent.themeChanged` and
  `AppEvent.localeChanged`.
- `AppBloc` persists both choices through `LocalDataStorage` under `StorageKeys.themeMode` and
  `StorageKeys.locale`, and restores them synchronously in its constructor, so the first frame
  already has the saved theme.

## Key files
- `lib/features/settings/presentation/view/settings_view.dart`
- `lib/features/settings/presentation/widgets/settings_section.dart`
- `lib/app/presentation/bloc/app_bloc.dart`
- `lib/app/presentation/view/app.dart`
- `test/features/settings/presentation/view/settings_view_test.dart`

## Gotchas
- The language options are hardcoded to `en` and `es` in the view. Adding a language needs a new
  ARB file in `lib/l10n/arb/`, a new segment in the view, and an entry in `CFBundleLocalizations` in
  `ios/Runner/Info.plist`.
- `AppBloc` stores the raw language code. A code with no ARB file falls back through
  `MaterialApp`'s locale resolution to the first supported locale.
- While the device-preview panel is enabled (the development flavor), its locale setting overrides
  the language chosen here.
