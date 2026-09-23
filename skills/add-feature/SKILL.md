---
name: add-feature
description: Scaffold a new clean-architecture feature module end to end in a flutter-agent-kit app — domain, data and presentation layers, DI annotations, endpoint wiring, codegen, registration, route, tests and feature doc. Use when adding a new feature area or a new API-backed screen flow.
---

# Add a feature module

Build the **model first**, then the rest of data, then domain, then presentation: the model is the
type every later layer names. Read the app's `.claude/rules/data-layer.md` and
`.claude/rules/state-management.md` first. App-specific facts there, such as the response envelope,
override this skill.

Layout (`lib/features/<feature>/`):

```
data/{datasources,models,repositories}
domain/{entities,repositories,usecases}
presentation/{bloc,cubit,mappers,view,widgets}
```

Create only the folders the feature needs. A presentation-only feature whose data comes from
`lib/core/services/*` has no `data/` or `domain/`. Code shared by two features belongs in
`lib/core/services/<name>/` with the same structure.

## 1. Endpoint
Add the path to `AppUrl` (`lib/core/constants/app_url.dart`). The base URL comes from
`Env.apiBaseUrl`; never hardcode a host.

## 2. Data layer
- `data/models/<name>_model.dart`: a freezed + json_serializable DTO matching the wire format, with
  every wire field nullable. This is the type the whole feature passes around. The base app has no
  JSON models, so before the first one run `fvm flutter pub add json_annotation`.
- `data/datasources/<name>_remote_datasource.dart`: `@LazySingleton(as: <Name>RemoteDatasource)`.
  Call `ApiClient` inside `InternetSafeRunner`, unwrap the envelope, and return the model.
- `data/repositories/<name>_repository_impl.dart`: `@LazySingleton(as: <Name>Repository)`. Wrap the
  datasource in `EitherSafeRunner` and return what it returned.

## 3. Domain layer
- `domain/repositories/<name>_repository.dart`: an **abstract** contract returning
  `Future<Either<Failure, <Name>Model>>`, or `Unit` when the response carries nothing the app uses.
- `domain/usecases/<action>_usecase.dart`: `@injectable`, extends `UseCase<Out, Params>`
  (`lib/core/usecase/usecase.dart`), with `NoParams` when there are no arguments. It only delegates
  to the repository. Its params class goes in the same file.
- `domain/entities/`: only what the wire has no row for — enums, a draft a multi-screen flow builds
  up, an action outcome, or a params class a second usecase now shares. No Flutter import.

## 4. Presentation layer
- `presentation/cubit/<name>_state.dart`: freezed **sealed** union of `initial` / `loading` /
  `success(data)` / `error(message)`, each variant a public class. Add `loadingMore` if the list is
  paginated (see the `paginate-list` skill).
- `presentation/cubit/<name>_cubit.dart`: `@lazySingleton`. Emit `loading`, await the usecase, then
  fold the result into `error(_failureToString(f))` or `success(d)`, with
  `static const _failureToString = ConvertFailureToString();`. No `isClosed` guard — a root cubit is
  never closed (see `.claude/rules/state-management.md`). If it holds per-visit state, add `reset()`
  and call it from the screen's `initState`.
- `presentation/view/<name>_view.dart`: the screen only. Wrap it in `CustomScaffold`, branch on state
  with `.when`/`.maybeWhen`, and move sub-widgets into `presentation/widgets/<view_stem>_widgets.dart`.
  Follow `.claude/rules/ui-conventions.md` ("Using a cubit in a view") for the builder and listener
  shape.
- `presentation/mappers/`: add one when a widget wants the model reshaped — a status enum, a label,
  or row view data. Keep the reshaping out of the view.

Blocs and cubits must not import `package:flutter/*`.

## 5. Register
Mount the cubit in `lib/app/presentation/view/app_bloc_provider.dart`:

```dart
BlocProvider<MyCubit>.value(value: sl<MyCubit>()),
```

If it has a `reset()`, add `sl<MyCubit>().reset();` to `resetAll()` in the same file, or to
`resetFlows()` when a signed-out screen uses it. Route-scope it instead only for the reasons in
`.claude/rules/state-management.md`.

## 6. Route
Follow the `add-route` skill.

## 7. Test
- **Model:** decode captured server JSON saved under `test/fixtures/<feature>/`.
- **Repository:** mock the datasource with mocktail; assert both the `Left` and `Right` paths.
  A `Left` comes from the exception the datasource throws, not from anything the repository maps.
- **Cubit:** `blocTest` with a mocked usecase. Call `registerFallbackValue` for params types in
  `setUpAll`.
- **View:** `pumpApp` from `test/helpers/`.

## 8. Document it
Create `docs/features/<feature>.md` with the six headings from `.claude/rules/feature-docs.md`.

## 9. Generate and verify
```sh
fvm dart run build_runner build
fvm flutter analyze
fvm dart run bloc_tools:bloc lint .   # only if .kit.json toolchain.has lists bloc_lint
fvm flutter test
```
Never hand-edit `injection.config.dart` or any `*.freezed.dart` / `*.g.dart`.
