---
name: add-route
description: Add a new screen route to a flutter-agent-kit app's go_router config — name, path, GoRoute entry, shell placement, nav-bar visibility, transition, typed extra and auth redirect sets when the app has them. Use when adding any new screen that must be navigable.
---

# Add a route

All route files live in `lib/config/navigators/`. Read the app's `.claude/rules/navigation.md`
first; it records this app's shell layout and any auth redirect.

## 1. Declare the name and the path
Every route needs **both**:

- `routes_names.dart`: `static const myScreen = 'myScreen';` (the go_router *name*)
- `routes_path.dart`: `static const myScreen = '/my-screen';` (the URL *path*)

You navigate by name. Redirect logic and nav-bar visibility match on the path.

## 2. Add the `GoRoute` in `routes_generator.dart`
Decide where the route belongs:

- **Inside a shell branch:** use a **relative** path; `'details'` under the home branch resolves to
  `/home/details`. The screen keeps the bottom navigation bar.
- **Cross-tab overlay or detail screen:** a **top-level** route with an absolute path. A screen on a
  top-level route may only push other top-level routes.

For a full-page overlay that slides up, use `pageBuilder` with
`CustomTransitionPage(child: ..., transitionsBuilder: slideUpTransition)`; `slideUpTransition` is
defined at the bottom of `routes_generator.dart`.

## 3. Nav-bar visibility
If an overlay must hide the bottom nav bar, add its path prefix to `hideNavRoutePrefixes`.

## 4. Typed `extra`
If you pass an object through `extra`, register its type in `AppExtraCodec`
(`app_extra_codec.dart`). Otherwise it won't survive state restoration.

## 5. Auth redirect (only if the app has one)
If `routes_generator.dart` has a `redirect` with public and signed-out-only path sets:

| Route kind | Public set | Signed-out-only set |
|---|---|---|
| Normal signed-in screen | no | no |
| Sign-in / sign-up | yes | yes |
| Onboarding wizard step | **yes** | **yes** |

Onboarding steps must be in **both** sets. In the public set only, a signed-in user mid-wizard gets
bounced away. In the signed-out-only set only, a signed-out user can't reach the screen. Either bug
shows up only partway through the flow.

## 6. Navigate
Always through `UiHelpers`, always by name:

```dart
UiHelpers.navigateTo(context, RoutesName.myScreen, extra: model);
```

## 7. Verify
- Open the route from where it will really be used, and confirm the nav bar shows or hides as
  intended.
- If the app has an auth redirect, test in both states: signed out and signed in.
- Update the feature doc's **Entry screens** section.
