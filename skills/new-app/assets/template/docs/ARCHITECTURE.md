# Architecture

Background reading, not loaded automatically. Conventions that every change must follow live in
`AGENTS.md` and `.claude/rules/`. Per-feature detail lives in [features/](features/).

## Overview

A Flutter app organized by feature with Clean Architecture (`data` / `domain` / `presentation`)
and flutter_bloc for state.

- Dependency injection: get_it + injectable.
- Networking: Dio + Retrofit.
- Models and state: freezed (+ json_serializable when a feature adds models).
- Routing: go_router.
- Storage: Hive CE for preferences and caches, flutter_secure_storage for secrets.
- Flavors: `development`, `staging` and `production`, both in Dart and natively.

Flutter is pinned with FVM (`.fvmrc`, Flutter 3.41.0, Dart `^3.11.0`); prefix every command with
`fvm`. `pubspec.yaml` is the authoritative dependency list.

The base app ships two presentation-only example features, [home](features/home.md) and
[settings](features/settings.md). It has no authentication, push notifications, analytics, crash
reporting, payments or location code.

## Entry & bootstrap

Three entry points each build a `FlavorConfig` (`lib/config/flavor/flavor_config.dart`: flavor,
env file, Hive box name, device-preview toggle) and call `bootstrap()`:

| Entry point | Env file | Native flavor |
|---|---|---|
| `lib/main_development.dart` | `.env.development` | `development` |
| `lib/main_staging.dart` | `.env.staging` | `staging` |
| `lib/main_production.dart` | `.env.production` | `production` |

`bootstrap()` (`lib/bootstrap.dart`):
1. Asserts that Flutter's `appFlavor` (set by `--flavor`), when present, matches
   `FlavorConfig.flavor.name`, so a mismatched entry point fails fast in debug.
2. Opens a `runZonedGuarded` zone and awaits `AppManager.initialize(config)`.
3. Runs `App`, wrapped in `DevicePreview` when the flavor enables it and in
   `DioRequestInspectorMain` outside production.

`AppManager.initialize()` (`lib/core/app_manager/app_manager.dart`) runs these steps in order, each
a private static method so a module can insert a step between two others:

1. `WidgetsFlutterBinding.ensureInitialized()`
2. Error handlers for `FlutterError.onError` and `PlatformDispatcher.instance.onError`
3. Portrait orientation lock
4. `dotenv.load()` of the flavor's env file
5. `Hive.initFlutter()`, `registerHiveAdapters()`, then open the flavor's box
6. Register `FlavorConfig` in `sl`
7. `configureDependencies()`
8. `Bloc.observer = const AppBlocObserver()`

`App` (`lib/app/presentation/view/app.dart`) builds a `MaterialApp.router` inside a
`MultiBlocProvider` (`AppBlocProvider.providers`). A `BlocBuilder<AppBloc, AppState>` drives
`themeMode` and `locale`. The router's `builder` installs `KeyboardDismissal` and the app-wide
`AppLoaderOverlay`.

Native flavor configuration:
- **Android:** `productFlavors` in `android/app/build.gradle.kts`, with `.dev` / `.stg`
  application-ID suffixes and an `appName` manifest placeholder for the launcher label.
- **iOS:** nine build configurations (`Debug`, `Profile` and `Release` for each flavor), one shared
  scheme per flavor, and per-configuration `PRODUCT_BUNDLE_IDENTIFIER` and `FLAVOR_APP_NAME`.
  `ios/Podfile` maps every configuration to `:debug` or `:release`.
- **iOS xcconfig layering:** project-level configurations use `ios/Flutter/Debug.xcconfig` or
  `Release.xcconfig` for Flutter's generated settings. Each Runner configuration uses its own
  `Pods-Runner.<type>-<flavor>.xcconfig` from CocoaPods; without it a flavored configuration has
  no `PODS_ROOT` and the build fails on the Pods frameworks file list.

## Folder layout

```
lib/
├── main_{development,staging,production}.dart   Flavor entry points
├── bootstrap.dart                 Zone guard, flavor assert, DevicePreview/inspector wrapping
├── app/presentation/
│   ├── bloc/                      AppBloc: persisted theme and locale
│   └── view/                      App, AppBlocProvider, registerHiveAdapters()
├── config/
│   ├── flavor/                    Flavor enum, FlavorConfig
│   ├── navigators/                AppRouter, RoutesName, RoutesPath, AppExtraCodec
│   └── theme/                     AppTheme, AppThemeColors, custom_theme/
├── core/
│   ├── app_manager/               AppManager.initialize()
│   ├── components/                Shared widgets
│   ├── constants/                 AppColor, AppGradient, AppSize, AppUrl, Env, Keys, StorageKeys, AppLinks
│   ├── error/                     Failure, ConvertFailureToString
│   ├── exception/                 AppException
│   ├── extensions/                String, date and Either extensions
│   ├── helpers/                   UiHelpers, KeyboardDismissal, PhoneCountry, Validators
│   ├── injections/                sl, configureDependencies, RegisterModule
│   ├── local_data/                LocalDataStorage (Hive), SecureLocalDataStorage
│   ├── network_info/              ApiClient, NetworkInfo, request inspector
│   └── usecase/                   UseCase, StreamUseCase, NoParams
├── features/
│   ├── home/presentation/         Example feature
│   └── settings/presentation/     Example feature
├── gen/                           flutter_gen output (assets, fonts)
├── l10n/                          ARB sources and the l10n extension; gen/ is generated
└── utils/                         logger, EitherSafeRunner, InternetSafeRunner
```

## Feature module pattern

A data-backed feature lives in `lib/features/<feature>/`:

```
data/
  datasources/    ApiClient calls inside InternetSafeRunner; unwrap the envelope; return models
  models/         Wire-format DTOs (freezed + json_serializable)
  repositories/   Implementations wrapping datasources in EitherSafeRunner
domain/
  entities/       Plain types the app reasons about
  repositories/   Abstract contracts returning Either<Failure, T>
  usecases/       One action each, extending UseCase
presentation/
  bloc/ cubit/    Freezed sealed states
  view/           Screens only
  widgets/        Widgets extracted from this feature's views
```

- `domain/` depends on nothing; `data/` and `presentation/` depend on `domain/`, never on each
  other. Presentation calls usecases, never repositories.
- A feature whose data comes from `lib/core/services/<name>/` is presentation-only, like both
  example features. Code shared by two features moves to `lib/core/services/<name>/` with the same
  three layers; a feature never imports another feature's internals.
- Every feature has a doc in `docs/features/` with six headings: Purpose, Entry screens,
  Endpoints, State, Key files, Gotchas.

## Core systems

### Dependency injection

- `sl` is the `GetIt` instance and `configureDependencies()` calls the injectable-generated
  `init(sl)` (`lib/core/injections/injection.dart`, output in `injection.config.dart`).
- `FlavorConfig` is registered by hand before `configureDependencies()`. `build_runner` therefore
  warns that `Box<dynamic>` and `Dio` depend on an unregistered `FlavorConfig`; that warning is
  expected.
- `RegisterModule` (`lib/core/injections/register_module.dart`) provides third-party singletons:
  the Hive `Box<dynamic>`, `InternetConnection`, `FlutterSecureStorage`, `Dio` and `ApiClient`.
- Annotations: datasources and repositories use `@LazySingleton(as: Abstract)`, usecases
  `@injectable`, blocs and cubits `@lazySingleton`.

### Routing

- `AppRouter.create(FlavorConfig)` in `lib/config/navigators/routes_generator.dart` builds the
  `GoRouter`. Every route has a name in `RoutesName` and a path in `RoutesPath`; code navigates by
  name through `UiHelpers` (`navigateTo`, `navigateForResult`, `replace`, `replaceStack`, `pop`).
- There is no redirect. `initialLocation` is `/home`, and unknown locations render `NotFoundView`.
- The shell is a `StatefulShellRoute.indexedStack` with a `home` branch and a `settings` branch,
  rendered by `CustomNavigationBar`. The bar takes its tabs as a list of `NavigationTab` (icon,
  label, root route name) and imports no feature; tapping the active tab returns to its root.
- An overlay that should hide the bar adds its path prefix to `hideNavRoutePrefixes` (empty in the
  base app). Full-page overlays can pass `slideUpTransition` as a `CustomTransitionPage`'s
  `transitionsBuilder`.
- Typed `extra` objects must be registered in `AppExtraCodec`, whose registry starts empty.
- Outside production the router logs diagnostics and adds the request inspector's navigator
  observer.

### Networking & errors

- `Dio` (a lazy singleton in `RegisterModule`) uses `Env.apiBaseUrl`, 20 s connect and 30 s
  send/receive timeouts, and `Accept: application/json`.
- Interceptors, in order: `PrettyDioLogger` (outside production), `RetryInterceptor` (retries after
  1, 2 and 3 seconds), and the request inspector (outside production).
- `ApiClient` (`lib/core/network_info/api_client.dart`) is a Retrofit client exposing generic verbs
  only (`getRequest`, `postRequest`, `putRequest`, `patchRequest`, `deleteRequest` and form-data
  variants). Endpoint paths are getters on `AppUrl`.
- The expected response envelope carries `message` and `data`. Datasources unwrap
  `(response.data as Map)['data']`.
- `InternetSafeRunner` checks `NetworkInfo` (internet_connection_checker_plus, which verifies real
  reachability) and throws `AppException.noInternet()` when offline.
- `AppException.fromDioError` maps timeouts to `timeout`, connection errors to `noInternet`, a 401
  to `unauthorized`, and any other bad response to `server`, reading `message` from a JSON map or a
  JSON string body.
- `EitherSafeRunner` turns exceptions into `Either<Failure, T>`; `ConvertFailureToString` renders a
  `Failure` for the UI. `UseCase`, `StreamUseCase` and `NoParams` are in
  `lib/core/usecase/usecase.dart`.

### Local storage

- Hive CE is initialized in `AppManager` before DI. Adapters go in `registerHiveAdapters()`
  (`lib/app/presentation/view/app_hive_adapters.dart`), and each flavor opens its own box
  (`FlavorConfig.hiveBoxName`).
- `LocalDataStorage` (`read`, `write`, `delete`, `clear`) wraps that box for preferences and caches.
- `SecureLocalDataStorage` wraps flutter_secure_storage (Keychain with `first_unlock`
  accessibility, EncryptedSharedPreferences on Android) for tokens and other secrets.
- Keys live in `StorageKeys`; the base app stores `themeMode` and `locale`.

### State management

- flutter_bloc throughout. Blocs and cubits are `@lazySingleton` and registered in
  `AppBlocProvider` as `BlocProvider<T>.value(value: sl<T>())`.
- `AppBloc` owns `AppThemeMode` and the language code. It restores both synchronously in its
  constructor and persists each change, so the first frame already has the saved theme.
- States are freezed sealed unions, and the UI branches with `.when` / `.maybeWhen`.
- Blocs and cubits never import Flutter; `bloc_lint` enforces this and its other rules, run with
  `fvm dart run bloc_tools:bloc lint .`.

### Theming

- `AppTheme.lightTheme` and `darkTheme` (`lib/config/theme/app_theme.dart`) combine a
  `ColorScheme.fromSeed(AppColor.primary)` with the component themes in `custom_theme/`, the Inter
  font (`FontFamily.inter`) and the `AppThemeColors` extension.
- `AppThemeColors` holds the 17 mode-varying roles (`textHeading`, `textSubheading`, `subtext`,
  `textLink`, `background`, `cards`, `cardFill`, `stroke`, `strokeFill`, `fill`, `divider`,
  `modalSurface`, `icon`, `iconBg`, `iconLow`, `iconInactive`, `primary`). Widgets read them with
  `AppThemeColors.of(context)`.
- `AppColor` holds mode-invariant primitives: an indigo primary, status colors, alpha overlays and
  a grey ramp. `AppGradient` holds shared gradients.
- `test/config/theme/app_theme_colors_test.dart` pins every role in both modes.

## Conventions

- **Comments:** one line, explaining why rather than what. Views carry none.
- **Generated code:** never hand-edited. `*.g.dart`, `*.freezed.dart`, `*.config.dart` and
  `lib/l10n/gen/` are gitignored. `lib/gen/*.gen.dart` (flutter_gen) is tracked.
- **Codegen commands:** `fvm dart run build_runner build --delete-conflicting-outputs`, and
  separately `fvm flutter gen-l10n`.
- **Assets:** referenced through flutter_gen (`Assets.images.appicon`), never by string path.
- **Localization:** ARB files in `lib/l10n/arb/` (English and Spanish), read with `context.l10n`.
- **UI:** screens use `CustomScaffold`, text input uses `CustomInputField`, feedback uses
  `UiHelpers.showToast` / `showLoader` / `showFeedbackSheet`, and async states use
  `LoadingIndicator`, `AppErrorState` and `AppEmptyState`.
- **Lints:** very_good_analysis through `fvm flutter analyze`, plus bloc_lint.
- **Running:** `make run-dev`, `make run-staging`, `make run-prod`; `make help` lists the build
  targets.

## Secrets

- `.env.development`, `.env.staging` and `.env.production` are committed and bundled as assets, so
  they may hold only client-restricted values. `.env.example` lists every key with an empty value.
  Values are read only through `Env`.
- Android release signing reads `android/key.properties`, or the `ANDROID_KEYSTORE_*` environment
  variables when set. Key files, keystores and service-account JSON are gitignored.
- The iOS `DEVELOPMENT_TEAM` is empty; set it in Xcode.

## CI

`.github/workflows/main.yaml` runs on pushes and pull requests to `development`, `staging` and
`production`:

- **Semantic pull request:** checks the PR title.
- **Build:** Very Good Workflows `flutter_package` on Flutter 3.41.x, with `dart run build_runner
  build` as setup, bloc_lint enabled, and a 50% minimum coverage measured without generated files.
  Formatting, analysis and tests follow that workflow's defaults.
- **Spell check:** runs over Markdown with `.github/cspell.json`.

Dependabot (`.github/dependabot.yaml`) checks pub packages and GitHub Actions daily, and
`.github/PULL_REQUEST_TEMPLATE.md` structures pull requests.

## Tests

`test/` mirrors `lib/`. Shared helpers are imported through `test/helpers/helpers.dart`:

- `pumpApp`: pumps a widget, or a `GoRouter`, under `AppTheme` light or dark with the l10n
  delegates, optionally providing an `AppBloc`.
- `StubHttpAdapter`: a Dio adapter that records requests and replies from a queue of scripted
  responses.
- `loadTestEnv`: loads env values with `dotenv.testLoad`, so `Env` getters work without a file.

Captured server JSON for model contract tests goes in `test/fixtures/<feature>/`. The base suite
covers:
- the shared components and helpers
- the theme palette
- `AppBloc` persistence
- both safe runners and `ApiClient` error handling
- the settings view
- a router test that opens on home and switches to the settings tab
