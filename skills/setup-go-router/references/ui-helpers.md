# The navigation facade

Detail for step 6 of `setup-go-router` — the full `UiHelpers` surface.


One door for all navigation. Feature code never imports `go_router`.

```dart
abstract class UiHelpers {
  static void navigateTo(
    BuildContext context,
    String routeName, {
    Map<String, String>? pathParameters,
    Map<String, String>? queryParameters,
    Object? extra,
  }) {
    unawaited(
      context.pushNamed(
        routeName,
        pathParameters: pathParameters ?? const {},
        queryParameters: queryParameters ?? const {},
        extra: extra,
      ),
    );
  }

  /// Like [navigateTo] but awaits the pushed route and returns the value it
  /// pops with (via [pop]).
  static Future<T?> navigateForResult<T>(
    BuildContext context,
    String routeName, {
    Map<String, String>? pathParameters,
    Map<String, String>? queryParameters,
    Object? extra,
  }) {
    return context.pushNamed<T>(
      routeName,
      pathParameters: pathParameters ?? const {},
      queryParameters: queryParameters ?? const {},
      extra: extra,
    );
  }

  static void replace(BuildContext context, String routeName, {/* same params */}) =>
      context.pushReplacementNamed(routeName, /* ... */);

  static void replaceStack(BuildContext context, String routeName, {/* same params */}) =>
      context.goNamed(routeName, /* ... */);

  static void pop<T extends Object?>(BuildContext context, [T? result]) => context.pop(result);
}
```

Keep `queryParameters` typed `Map<String, String>` on **all four** — a `Map<String, dynamic>` here
silently stringifies whatever you pass and the bug surfaces as a parse failure in the receiving
route.

| Instead of | Use |
|---|---|
| `context.pushNamed(...)` / `GoRouter.of(context).push(...)` | `UiHelpers.navigateTo(context, RoutesName.x, extra: e)` |
| `context.go(...)` | `UiHelpers.replaceStack(context, RoutesName.x)` |
| `context.pushReplacementNamed(...)` | `UiHelpers.replace(...)` |
| `Navigator.pop(context, result)` | `UiHelpers.pop(context, result)` |

Always pass `RoutesName.*`, never `RoutesPath.*`. `UiHelpers.pop` works for screens, sheets and
dialogs alike and forwards the result.

Sanctioned `Navigator.*` exceptions — everything else is a lint-by-review failure:

1. `UiHelpers`' own internal `Navigator.pop` inside Cupertino pickers and confirm dialogs.
2. `Navigator.of(context).canPop()` as a read-only query (e.g. deciding whether to draw a back
   button).
3. `Navigator.of(sheetContext).pop()` inside a locally-scoped bottom sheet.
4. `Navigator.of(context, rootNavigator: true).pop()` to dismiss a root-level loading dialog.

Enforce it: `grep -rn "context\.push\|context\.go\|GoRouter\.of" lib/ --include=*.dart` should
return hits only in `ui_helpers.dart`.

A screen that needs specific arguments should hide the route name behind a `static open`:

```dart
static void open(BuildContext context, {required String imageUrl, Object? heroTag}) {
  UiHelpers.navigateTo(
    context,
    RoutesName.photoView,
    extra: PhotoViewerArgs(imageUrl: imageUrl, heroTag: heroTag),
  );
}
```
