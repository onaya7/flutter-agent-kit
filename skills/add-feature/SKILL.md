---
name: add-feature
description: Scaffold a new clean-architecture feature module end to end in a flutter-agent-kit app — domain, data and presentation layers, DI annotations, endpoint wiring, codegen, registration, route, tests and feature doc. Use when adding a new feature area or a new API-backed screen flow.
---

# Add a feature module

Build the **domain layer first**, then data, then presentation; that order makes a boundary violation
impossible to write by accident. Read the app's `.claude/rules/data-layer.md` and
`.claude/rules/state-management.md` first. App-specific facts there, such as the response envelope,
override this skill.

Layout (`lib/features/<feature>/`):

```
data/{datasources,models,repositories}
domain/{entities,repositories,usecases}
presentation/{bloc,cubit,view,widgets}
```

Create only the folders the feature needs. A presentation-only feature whose data comes from
`lib/core/services/*` has no `data/` or `domain/`. Code shared by two features belongs in
`lib/core/services/<name>/` with the same structure.

## 1. Endpoint
Add the path to `AppUrl` (`lib/core/constants/app_url.dart`). The base URL comes from
`Env.apiBaseUrl`; never hardcode a host.

## 2. Domain layer (depends on nothing)
- `domain/entities/`: plain classes and enums the app reasons about. No Flutter import, no JSON.
- `domain/repositories/<name>_repository.dart`: an **abstract** contract returning
  `Future<Either<Failure, T>>`.
- `domain/usecases/<action>_usecase.dart`: `@injectable`, extends `UseCase<Out, Params>`
  (`lib/core/usecase/usecase.dart`), with `NoParams` when there are no arguments. It only delegates
  to the repository.

## 3. Data layer
- `data/models/<name>_model.dart`: a freezed + json_serializable DTO matching the wire format, plus
  a mapping to its entity. Models never appear in `domain/` or `presentation/`. The base app has no
  JSON models, so before the first one run `fvm flutter pub add json_annotation`.
- `data/datasources/<name>_remote_datasource.dart`: `@LazySingleton(as: <Name>RemoteDatasource)`.
  Call `ApiClient` inside `InternetSafeRunner`, unwrap the envelope, and return the model.
- `data/repositories/<name>_repository_impl.dart`: `@LazySingleton(as: <Name>Repository)`. Wrap the
  datasource in `EitherSafeRunner` and map models to entities.

## 4. Presentation layer
- `presentation/cubit/<name>_state.dart`: freezed **sealed** union of `initial` / `loading` /
  `success(data)` / `error(message)`. Add `loadingMore` if the list is paginated (see the
  `paginate-list` skill).
- `presentation/cubit/<name>_cubit.dart`: `@lazySingleton`. Emit `loading`, await the usecase, then
  `result.fold((f) => emit(error(ConvertFailureToString(f))), (d) => emit(success(d)))`. If it holds
  per-screen state, add `reset()` and call it from the screen's `initState`.
- `presentation/view/<name>_view.dart`: the screen only. Wrap it in `CustomScaffold`, branch on state
  with `.when`/`.maybeWhen`, and move sub-widgets into `presentation/widgets/<view_stem>_widgets.dart`.

Blocs and cubits must not import `package:flutter/*`.

## 5. Register
Add the cubit to `lib/app/presentation/view/app_bloc_provider.dart`:

```dart
BlocProvider<MyCubit>.value(value: sl<MyCubit>()),
```

## 6. Route
Follow the `add-route` skill.

## 7. Test
- **Model:** decode captured server JSON saved under `test/fixtures/<feature>/`.
- **Repository:** mock the datasource with mocktail; assert both the `Left` and `Right` paths.
- **Cubit:** `blocTest` with a mocked usecase. Call `registerFallbackValue` for params types in
  `setUpAll`.
- **View:** `pumpApp` from `test/helpers/`.

## 8. Document it
Create `docs/features/<feature>.md` with the six headings from `.claude/rules/feature-docs.md`.

## 9. Generate and verify
```sh
fvm dart run build_runner build
fvm flutter analyze
fvm dart run bloc_tools:bloc lint .
fvm flutter test
```
Never hand-edit `injection.config.dart` or any `*.freezed.dart` / `*.g.dart`.
