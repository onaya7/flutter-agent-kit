# The auth guard, refresh and transitions

Detail for step 3 of `setup-go-router`. Read that skill first; this file is the long form of the
router's guard, its refresh wiring and its page transitions.

#### The auth guard

Two `const Set<String>` of **paths**, and a redirect that is a plain top-level function — it takes
the state and a string, not a `GoRouterState`, which is what makes it unit-testable.

```dart
const _publicPaths = <String>{
  RoutesPath.splash,
  RoutesPath.signIn,
  RoutesPath.signUp,
  RoutesPath.onboarding,
  // ... every onboarding / password-reset step
};

const _authOnlyPaths = <String>{
  RoutesPath.signIn,
  RoutesPath.signUp,
  // ... the sign-up wizard steps, again
};

String? _redirect(AuthState state, String location) {
  final isResolving = state.maybeWhen(
    initial: () => true,
    loading: () => true,
    orElse: () => false,
  );
  if (isResolving) return null; // don't bounce while the session resolves

  final isAuthed = state.maybeWhen(
    authenticated: (_) => true,
    orElse: () => false,
  );
  final isPublic = _publicPaths.contains(location);

  if (!isAuthed && !isPublic) return RoutesPath.signIn;
  if (isAuthed && _authOnlyPaths.contains(location)) return RoutesPath.home;
  return null;
}
```

**The `isResolving` early return is not optional.** Without it, cold start reads the pre-hydration
state, decides the user is signed out, and throws them to `/sign-in` a frame before the token
loads.

Which set does a route go in? This table is the thing people get wrong:

| Route kind | `_publicPaths` | `_authOnlyPaths` |
|---|---|---|
| Normal authenticated screen | no | no |
| Sign-in / sign-up | **yes** | **yes** |
| **Any onboarding wizard step** | **yes** | **yes** |

Wizard steps go in **both**. In `_publicPaths` only, an authenticated user mid-wizard is bounced to
`/home`. In `_authOnlyPaths` only, a signed-out user can't reach the step at all. Either bug shows
up partway through a flow, which is why it survives a quick smoke test.

The matching `AuthState` (freezed sealed union):

```dart
@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState.initial() = AuthInitial;
  const factory AuthState.loading() = AuthLoading;
  const factory AuthState.authenticated(UserModel? user) = AuthAuthenticated;
  const factory AuthState.unauthenticated() = AuthUnauthenticated;
  const factory AuthState.error(String message) = AuthError;
}
```

#### Re-running the guard when auth changes

`redirect` only re-evaluates on navigation, so a logout while sitting on a screen changes nothing
until `refreshListenable` fires. Bridge the bloc stream to a `ChangeNotifier` at the bottom of the
router file:

```dart
class _AuthRefreshListenable extends ChangeNotifier {
  _AuthRefreshListenable(Stream<AuthState> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<AuthState> _sub;

  @override
  void dispose() {
    unawaited(_sub.cancel());
    super.dispose();
  }
}
```

That completes the force-logout chain: `401` → repository clears the token → `AuthBloc` emits
`unauthenticated` → listenable notifies → `redirect` bounces to `/sign-in`.

#### Transitions

Two module-level functions, reused by every route that needs them:

```dart
/// A bottom-to-top slide for full-page detail routes.
Widget _slideUpTransition(
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

/// A plain fade for overlays that rely on a Hero flight, so the backdrop dims
/// in while the Hero lands.
Widget _fadeTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) => FadeTransition(opacity: animation, child: child);
```

Pick per route: `builder:` for plain flow screens (platform default transition),
`pageBuilder:` + `CustomTransitionPage` for overlays and detail screens. **Always pass
`key: state.pageKey`** — without it go_router cannot tell two instances of the same page apart.

```dart
pageBuilder: (context, state) => CustomTransitionPage<void>(
  key: state.pageKey,
  child: const ServicesView(),
  transitionsBuilder: _slideUpTransition,
),
```

Add `opaque: false` for a viewer that should show the previous screen behind it.
