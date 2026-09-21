---
name: setup-go-router
description: Bootstrap go_router navigation in a Flutter project that does not have it yet — route name/path constants, auth redirect, StatefulShellRoute tabs, extra codec, and a UiHelpers navigation facade. Also covers migrating off Navigator 1.0 / Provider-based routing. Use only when the project has no GoRouter config; use add-route to add a screen to an existing router.
---

# Set up go_router + navigation

A production-tested wiring for go_router with bloc, freezed and injectable. Every code block below
is lifted from a shipping app; adapt the names, keep the structure.

**Scope check:** if `GoRouter(` already exists in the project, stop — you want the `add-route`
skill, not this one.

The parts that go wrong in a fresh setup are, in order: the auth redirect firing before the session
has resolved, the redirect's two path sets, and typed `extra` blowing up after a restore. Those get
the most attention below.

## Two strategies for the session

Everything in Part 1 uses the **declarative** one: `redirect` + `refreshListenable`. It is the right
default for a greenfield router and a simple signed-in/signed-out session, and it is the shorter
path to something working.

The **imperative** alternative drops both and gives one `SessionManager` sole ownership of ending a
session: it clears storage, toasts, and navigates through a context-free `AppNavigator` that holds
the `GoRouter`. Guarding moves from the redirect to a `SessionGuard` widget wrapping the routes that
need a session. An app running this records it in its own `.claude/rules/navigation.md`.

Prefer it when any of these bite:

1. **`redirect` re-runs on every navigation** and will fight an imperative `push`. Once several
   places navigate deliberately, the two authorities disagree and the bug appears mid-flow.
2. **`refreshListenable` has no disposal owner.** go_router only removes its listener
   (`information_provider.dart`), so a `ChangeNotifier` built inline in the `GoRouter(...)` call is
   leaked with no reference left to dispose it.
3. **A redirect cannot say why.** "Your session expired" needs a second mechanism anyway, and that
   second mechanism ends up owning the navigation too.
4. **The session has more than two states** — locked, expired-vs-signed-out, mid-wizard — each of
   which the redirect must encode as another path set.

What the imperative model costs you: a redirect guards *every* navigation for free, so dropping it
means the cold-start and deep-link cases become checkpoints you have to build and test yourself.

## Part 0 — Dependencies

```yaml
dependencies:
  go_router: ^16.1.0
  flutter_bloc: ^9.1.1
  bloc: ^9.2.0
  freezed_annotation: ^3.0.0
  json_annotation: ^4.9.0
  get_it: ^8.0.3
  injectable: ^2.5.0

dev_dependencies:
  build_runner: ^2.4.13
  freezed: ^3.0.0
  json_serializable: ^6.9.0
  injectable_generator: ^2.6.2
```

After any change to a `@freezed` or `@injectable` class:

```sh
fvm dart run build_runner build
```

Target layout:

```
lib/
  config/navigators/
    routes_names.dart        # go_router names
    routes_path.dart         # URL paths
    routes_generator.dart    # the GoRouter itself
    app_extra_codec.dart     # extra serialization
  core/constants/keys.dart   # global navigator keys
  core/helpers/ui_helpers.dart  # the only navigation entry point
```

## Part 1 — Setup

### 1. Global keys — `lib/core/constants/keys.dart`

Keys live outside the router file so non-router code (a context-free loader overlay, a global
`ScaffoldMessenger`, a programmatic drawer open) can reach them without importing the router.

```dart
import 'package:flutter/material.dart';

abstract class Keys {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static final GlobalKey<ScaffoldState> shellScaffoldKey = GlobalKey<ScaffoldState>();
}
```

Add a `GlobalKey<ScaffoldMessengerState>` only when something reads it. A design system that has
settled on toasts never will, and an unread one is a standing invitation to reach for a `SnackBar`.

`navigatorKey.currentContext` is the **root navigator's** context, so it resolves anything *above*
`MaterialApp.router` — `InheritedGoRouter`, root providers, `Theme`. It cannot reach the router's
`Overlay`, which is its descendant; `Overlay.maybeOf` there silently returns null.

### 2. Names and paths — two files, every route in both

```dart
// routes_names.dart — the go_router *name*. You navigate by these.
abstract class RoutesName {
  static const splash = 'splash';
  static const signIn = 'sign-in';
  static const home = 'home';
  static const services = 'services';
  static const userProfile = 'user-profile';
}
```

```dart
// routes_path.dart — the URL *path*. The redirect matches on these.
abstract class RoutesPath {
  static const splash = '/';
  static const signIn = '/sign-in';
  static const home = '/home';

  // Nested under the home branch → resolves to '/home/services'. No leading slash.
  static const services = 'services';

  // Top-level so it can open over any tab.
  static const userProfile = '/user-profile';
}
```

Rules that hold for the life of the project:

- **Both files, always.** A name with no path (or vice versa) fails at runtime, not compile time.
- **kebab-case** for both values, mirroring each other (`RoutesName.signIn = 'sign-in'`,
  `RoutesPath.signIn = '/sign-in'`).
- A path is **relative** (no leading `/`) when nested inside a shell branch, **absolute** when it is
  a top-level overlay. Leave a one-line `//` comment on every relative path saying which branch it
  hangs off — that comment is what stops the next person from "fixing" the missing slash.

### 3. The router — `routes_generator.dart`

```dart
class RoutesGenerator {
  RoutesGenerator._();

  static GoRouter create(AuthBloc authBloc) {
    return GoRouter(
      navigatorKey: Keys.navigatorKey,
      extraCodec: const AppExtraCodec(),
      observers: const [],
      initialLocation: RoutesPath.splash,
      refreshListenable: _AuthRefreshListenable(authBloc.stream),
      redirect: (context, state) => _redirect(authBloc.state, state.uri.path),
      debugLogDiagnostics: kDebugMode,
      routes: [
        GoRoute(
          path: RoutesPath.splash,
          name: RoutesName.splash,
          builder: (_, __) => const SplashView(),
        ),
        // ... top-level routes ...
        _buildMainNavigationRoutes(), // the shell goes LAST
      ],
      errorBuilder: (_, __) => const NotFoundView(),
    );
  }
}
```

Notes: `errorBuilder` (not `errorPageBuilder`) renders an in-app 404 — give it a button that calls
`UiHelpers.replaceStack(context, RoutesName.home)` so users can recover. `observers` is where a
debug request inspector or analytics observer goes; gate it on flavor rather than shipping it.

#### The guard, the refresh and transitions

The redirect, its two path sets, `refreshListenable` and the page transitions are the longest part
of this file and the part most often got wrong. They live in
**`references/auth-guard.md`** — read it before writing the router.

### 4. `extra` serialization — `app_extra_codec.dart`

Skipping this produces a bug you will not reproduce by hand: go_router JSON-encodes `extra` on a
platform route-info round-trip (state restoration, process-death restore) and decodes it into a
plain `Map`, so the route's `state.extra as MyModel` cast throws on resume.

```dart
import 'dart:convert';

/// Codec for go_router's `extra`. Round-trips serializable domain objects so
/// they come back strongly typed, passes primitives through, and drops
/// anything non-serializable to null (records, File, mock data — the routes'
/// own fallbacks handle those).
class AppExtraCodec extends Codec<Object?, Object?> {
  const AppExtraCodec();

  @override
  Converter<Object?, Object?> get encoder => const _AppExtraEncoder();

  @override
  Converter<Object?, Object?> get decoder => const _AppExtraDecoder();
}

class _AppExtraEncoder extends Converter<Object?, Object?> {
  const _AppExtraEncoder();

  @override
  Object? convert(Object? input) => switch (input) {
    null || String() || num() || bool() => input,
    final MyModel m => {'t': 'myModel', 'v': m.toJson()},
    _ => null,
  };
}

class _AppExtraDecoder extends Converter<Object?, Object?> {
  const _AppExtraDecoder();

  @override
  Object? convert(Object? input) {
    if (input is Map && input['t'] == 'myModel') {
      return MyModel.fromJson(Map<String, dynamic>.from(input['v'] as Map));
    }
    return input;
  }
}
```

Tagged-union `{'t': tag, 'v': json}` envelope; add one `case` per serializable type. Because
unknown types encode to `null`, the standing rule in every route is:

```dart
child: MyView(model: state.extra as MyModel? ?? const MyModel()),
```

Never `state.extra! as T` unless the route is genuinely unreachable without it.

### 5. Tabs — `StatefulShellRoute` + the nav bar

Tabs are a `StatefulShellRoute.indexedStack` whose branches each keep their own `Navigator`, so a
tab remembers its stack. It goes **last** in `routes`, after every top-level route, and the shell
builder renders the nav bar. Switching tabs is `navigationShell.goBranch(...)`, the one sanctioned
place that touches `StatefulNavigationShell` directly rather than going through `UiHelpers`.

Full wiring, including re-tap-to-pop-to-root and per-branch drawer control:
**`references/shell-tabs.md`**.

### 6. The navigation facade — `lib/core/helpers/ui_helpers.dart`

One door for all navigation: `navigateTo`, `navigateForResult<T>`, `replace`, `replaceStack` and
`pop`, each taking a `RoutesName` rather than a path. **Feature code never imports `go_router`** —
that is the invariant the facade exists to hold, and the grep in Part 4 is what enforces it.

The full surface, with the result-passing and typed-`extra` call sites:
**`references/ui-helpers.md`**.

### 7. Wire into the app widget

```dart
class _AppState extends State<App> {
  late final GoRouter _router = RoutesGenerator.create(sl<AuthBloc>());

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: AppBlocProvider.providers,
      child: BlocBuilder<AppBloc, AppState>(
        builder: (context, state) {
          return MaterialApp.router(
            scaffoldMessengerKey: Keys.scaffoldMessengerKey,
            routerConfig: _router,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: state.themeMode,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
```

Three things here are deliberate:

- **`App` is a `StatefulWidget` solely to hold the router.** Building the `GoRouter` inside
  `build()` recreates it on every theme/locale rebuild and resets the navigation stack.
- **`routerConfig:`**, not the `routerDelegate` / `routeInformationParser` triple.
- **The router is not registered in DI** *in this strategy*, because it depends on `AuthBloc`
  (`@lazySingleton`, resolved via `sl<AuthBloc>()`) and that would risk a construction-order cycle.
  Note the reason evaporates under the imperative strategy: with no `redirect`, the router takes no
  arguments, so it belongs in a `@lazySingleton AppNavigator` that owns and disposes it. Keep that
  class's constructor argument-free — a dependency leading back to `Dio` closes the cycle for real,
  and get_it only reports it at first resolve, at boot.

## Part 2 — Adding a route

Use the **`add-route`** skill. It covers the name/path pair, shell placement, nav-bar visibility,
typed `extra`, the redirect's two path sets and how to pass arguments.

## Part 3 — Migrating from Provider + Navigator 1.0

| Before (Provider, Navigator 1.0) | After (bloc, go_router) |
|---|---|
| `MaterialApp(routes: {...})` / `onGenerateRoute:` | `MaterialApp.router(routerConfig: _router)` |
| `Navigator.pushNamed(context, '/x', arguments: a)` | `UiHelpers.navigateTo(context, RoutesName.x, extra: a)` |
| `ModalRoute.of(context)!.settings.arguments as A` | `state.extra as A? ?? fallback`, read in the `GoRoute` |
| `Navigator.pushReplacementNamed(...)` | `UiHelpers.replace(...)` |
| `Navigator.pushNamedAndRemoveUntil(...)` | `UiHelpers.replaceStack(...)` |
| `Navigator.pop(context, r)` | `UiHelpers.pop(context, r)` |
| `Consumer<AuthProvider>` swapping Login/Home | `redirect` + `refreshListenable` on the router |
| `ChangeNotifierProvider<AuthProvider>` | `AuthBloc` (`@lazySingleton`) + freezed `AuthState` union |
| `BottomNavigationBar` + `IndexedStack` in a widget | `StatefulShellRoute.indexedStack` branches |

Order matters — this sequence keeps the app runnable at every commit:

1. **Land `AuthBloc` + `AuthState` first**, with the old `AuthProvider` still in place and
   delegating to it. Nothing routes off the bloc yet.
2. **Create the four navigator files**, registering only the routes that exist today. Leave
   `_publicPaths` generous at this stage.
3. **Flip `MaterialApp` → `MaterialApp.router`.** The whole app moves at once; there is no partial
   mode.
4. **Convert call sites feature by feature**, replacing `Navigator.*` with `UiHelpers.*` and moving
   `settings.arguments` reads into the route's `extra`. Grep for `Navigator.` after each feature.
5. **Move the tab scaffold onto the shell route** and delete the hand-rolled `IndexedStack`.
6. **Tighten `_publicPaths` and delete the Provider gate widget last**, once `redirect` demonstrably
   covers every path. This is the step that breaks flows if done early.

The biggest conceptual shift: with Navigator 1.0 the *widget tree* decided whether you saw Login or
Home. With go_router the *router* decides, from `AuthState`, on every navigation. Any leftover
"if not logged in, show LoginPage" widget will fight the redirect — delete them rather than layering
the two.

## Part 4 — Pitfalls

- **`hideNavRoutePrefixes` as string literals.** Compose from `RoutesPath` consts; a renamed path
  otherwise leaves a rule that silently no longer matches.
- **`Map<String, dynamic> queryParameters`.** Type it `Map<String, String>` everywhere.
- **The redirect matches by exact `Set.contains`.** The moment you add a public route with a path
  parameter (`/reset/:token`) or a nested public path, exact matching stops working — switch to
  `_publicPaths.any(location.startsWith)` before that lands, not after.
- **`debugLogDiagnostics: true` unconditionally.** Gate on `kDebugMode` or flavor; it is verbose and
  logs navigation in production otherwise.
- **`state.extra!` casts.** Any route reachable after a process-death restore will crash. Use
  `as T? ?? fallback`.
- **Building the router in `build()`.** Resets the stack on every rebuild.

`_redirect` is pure, so test it from day one — the guard is the part with real branching logic:

```dart
void main() {
  group('_redirect', () {
    test('holds still while the session resolves', () {
      expect(redirect(const AuthState.loading(), RoutesPath.home), isNull);
    });

    test('bounces a signed-out user off a private path', () {
      expect(
        redirect(const AuthState.unauthenticated(), RoutesPath.home),
        RoutesPath.signIn,
      );
    });

    test('bounces a signed-in user off sign-in', () {
      expect(
        redirect(const AuthState.authenticated(null), RoutesPath.signIn),
        RoutesPath.home,
      );
    });

    test('leaves a signed-in user on a wizard step', () {
      expect(
        redirect(const AuthState.authenticated(null), RoutesPath.proSetupBasics),
        isNull,
      );
    });
  });
}
```

Make `_redirect` package-visible (`redirect`, or `@visibleForTesting`) to test it directly.

## Part 5 — Verify

- `flutter analyze` is clean.
- The app boots to `initialLocation` and lands on the right screen for a signed-out **and** a
  signed-in cold start.
- Every route opens in **both** auth states — this is where the two-set mistake shows up.
- The nav bar shows and hides as intended; re-tapping the active tab pops that branch to its root.
- `UiHelpers.pop(context, result)` delivers the result to an awaiting `navigateForResult`.
- An unknown path renders the error view, and its recovery button returns to home.
- Background the app, let the OS kill it, resume — routes carrying `extra` restore without a cast
  exception.
- `grep -rn "context\.push\|context\.go\|GoRouter\.of" lib/ --include=*.dart` returns hits only in
  `ui_helpers.dart`.
