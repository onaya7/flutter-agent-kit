---
paths:
  - "lib/**/bloc/**"
  - "lib/**/cubit/**"
  - "lib/**/*_state.dart"
  - "lib/app/presentation/view/app_bloc_provider.dart"
---

# State management

## State shape
State classes are freezed **sealed** unions with `initial` / `loading` / `success(data)` /
`error(message)`, plus `loadingMore` when the list is paginated:

```dart
@freezed
sealed class OrdersState with _$OrdersState {
  const factory OrdersState.initial() = OrdersInitial;
  const factory OrdersState.loading() = OrdersLoading;
  const factory OrdersState.success(List<OrderModel> data) = OrdersSuccess;
  const factory OrdersState.error(String message) = OrdersError;
}
```

Name each variant class publicly. `listenWhen`, `buildWhen` and tests use `state is OrdersSuccess`,
which does not compile against a private name.

A cubit emits `loading`, awaits the usecase, then folds the result. `ConvertFailureToString` is a
const callable class, so keep one instance and call it:

```dart
static const _failureToString = ConvertFailureToString();

Future<void> load() async {
  emit(const OrdersState.loading());
  final result = await _getOrders(const NoParams());
  result.fold(
    (f) => emit(OrdersState.error(_failureToString(f))),
    (d) => emit(OrdersState.success(d)),
  );
}
```

In the UI, branch with `.when` / `.maybeWhen` / `.whenOrNull`, **never** `switch` or `is`. Other
layers, such as a router redirect or a Dio interceptor, may use `switch` and `is` freely. How views
consume a cubit is in `.claude/rules/ui-conventions.md`.

## Registration and lifetime
**Root by default.** A bloc or cubit is `@lazySingleton` and mounted once in
`lib/app/presentation/view/app_bloc_provider.dart` as `BlocProvider<T>.value(value: sl<T>())`, which
`App` hands to the `MultiBlocProvider` above `MaterialApp.router`. One instance per process is what
lets a multi-screen wizard keep its draft and a shared options list keep its cache.

Because they outlive any one screen:

- **A cubit holding per-visit state exposes `reset()`.** Who calls it depends on the scope of the
  state: the owning screen's `initState` for a single screen, the navigation site that *starts* a
  wizard (never a step, or stepping back would wipe the draft), and a single `resetAll()` on
  sign-out.
- **Put `resetAll()` in `app_bloc_provider.dart`, beside `providers`,** so registering a cubit and
  clearing it are one edit, and call it from wherever the app observes `unauthenticated`. A
  hand-maintained list kept somewhere else drifts: a real app reached 16 of 76 providers cleared,
  and the rest carried one account's data into the next session.
  `test/conventions/conventions_test.dart` fails when a mounted cubit defines `reset()` and
  `resetAll()` omits it, and when a `@lazySingleton` cubit is not mounted at all.
- **`reset()` returns to the cheapest correct state, not always `initial()`.** A cubit caching a
  fetched list goes back to its loaded arm and its `load()` returns early when already filled;
  a cubit holding a draft outside the state clears that field too.
- Cache the raw server data in the cubit and derive filtered or sorted lists at emit time. Don't
  overwrite the cache with a filtered copy.
- **Never give a root cubit a `@disposeMethod`** — a closed singleton throws "Cannot emit after
  close" the next time a screen mounts.

### Route scope is the exception, and the reason goes at the route
Use `@injectable` with `BlocProvider<T>(create: (_) => sl<T>(), child: …)` in the `GoRoute` only when
a shared instance would be wrong, and say why in one line there:

- a **boot-once** cubit whose `Completer` or `Timer` must not be reused, and whose `close()` matters;
- a **one-shot latch** a second visit has to clear;
- a screen **keyed to an item**, where a second push must not show the first's row.

Reach for it rather than bolting an id token onto a singleton and then re-checking that id in the
view — that is three mechanisms doing what a fresh instance does for free.

- **A route-scoped cubit guards every `emit` that follows an `await` with `if (isClosed) return;`.**
  `BlocProvider(create:)` owns the instance and closes it on pop, so a back-swipe mid-request makes
  the next `emit` throw `StateError`. A root cubit needs no guard — `.value` does not own it and no
  registration carries a `dispose:` — so don't scatter the guard by habit.
  `test/conventions/conventions_test.dart` fails on an `@injectable` cubit that awaits without one.

## bloc_lint rules: `flutter analyze` does NOT catch these
`analysis_options.yaml` includes `package:bloc_lint/recommended.yaml`, but those rules live under a
`bloc:` key the Dart analyzer ignores. Run them explicitly:

```sh
fvm dart run bloc_tools:bloc lint .
```

This whole section applies only when the app actually has bloc_lint — check that
`jq -r '.toolchain.has[]?' .kit.json` lists `bloc_lint`. An app on flutter_bloc 8.x has
neither package, and the command fails outright; the conventions above still hold, they are
just unenforced.

The CLI prints its own update prompt *after* the result, so read the `N issues found` line above
that box rather than the tail of the output.

| Rule | Meaning |
|---|---|
| `avoid_flutter_imports` | No `package:flutter/*` import in a bloc or cubit. Use framework-agnostic types (for example an `AppThemeMode` enum and a `String languageCode`) and convert at the `MaterialApp` boundary. |
| `avoid_public_bloc_methods` | Blocs communicate through events, not public methods. |
| `avoid_public_fields` | No mutable public fields on a bloc or cubit; state goes in the state class. |
| `prefer_file_naming_conventions` | `*_bloc.dart`, `*_event.dart`, `*_state.dart`, `*_cubit.dart`. |
| `prefer_void_public_cubit_methods` | Public cubit methods return `void` or `Future<void>`; results are emitted as state. |

CI runs these, so a violation fails the build even when `flutter analyze` passes locally.

**Without bloc_lint nothing enforces this table.** An app on flutter_bloc 8.x has neither package,
and `flutter analyze` sees none of these rules — so `avoid_flutter_imports` and
`avoid_public_fields` in particular drift quietly, and a public field a view reads in `build` keeps
rendering only while every mutation happens to sit between two emits.
`test/conventions/conventions_test.dart` asserts those two directly; keep it when the app has no
bloc_lint, delete those cases when it does.

A fresh app reports zero bloc_lint warnings. Public pagination getters such as `hasMore` and
`cachedData` trigger `prefer_void_public_cubit_methods`, because the rule can't tell a getter from a
method. Those warnings are expected; leave them. Any other warning is new, and yours to fix.

## Pagination
When a list endpoint's response carries `totalPages`/`totalElements`, implement incremental loading
instead of stopping at page 1. Follow the `paginate-list` skill.
