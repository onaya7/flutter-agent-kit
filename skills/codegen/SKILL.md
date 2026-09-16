---
name: codegen
description: Run the right code generator in a flutter-agent-kit app — build_runner for freezed, json_serializable, retrofit, injectable, hive and flutter_gen, or gen-l10n for localization. Use after editing annotated classes, assets or ARB files, or when a *.freezed.dart / *.g.dart / assets.gen.dart symbol is missing.
---

# Codegen

There are two independent generators, and running the wrong one produces a confusing "getter isn't
defined" error.

| You changed | Run |
|---|---|
| A `@freezed` class, `@JsonSerializable`, a Retrofit interface, an `@injectable`/`@lazySingleton` annotation, a Hive adapter | `fvm dart run build_runner build` |
| `pubspec.yaml` assets, or added/renamed a file under `assets/` | the same `build_runner` command (flutter_gen) |
| `lib/l10n/arb/*.arb` | `fvm flutter gen-l10n` |

`build_runner` does **not** generate localization, and `gen-l10n` generates nothing else.

## Stale output is handled for you
`build_runner` 2.16 made "always fix incorrect generated files" the default and removed
`--delete-conflicting-outputs`; passing it now logs a warning and does nothing. Use
`--keep-modified-outputs` only when hand edits to generated files must survive, and
`dart run build_runner clean` for a hard reset.

In CI, `--only-check` builds and compares against the files on disk without writing, failing if
anything differs. That catches a stale committed output without changing the tree.

## Never hand-edit output
`*.g.dart`, `*.freezed.dart`, `*.config.dart`, `*.gen.dart` and `lib/l10n/gen/` are all generated.
Change the annotated source and regenerate.

## Commit rules differ per output
See the app's `.claude/rules/generated-code.md`. The trap is that `lib/gen/assets.gen.dart` and
`lib/gen/fonts.gen.dart` **are tracked in git**. After adding an asset, regenerate *and commit* them,
or every teammate gets a missing-getter build break. Other `build_runner` outputs and
`lib/l10n/gen/` are ignored and must not be committed.

## After generating
```sh
fvm flutter analyze
```
`lib/gen/*.gen.dart` isn't excluded from analysis, so a generator upgrade can surface real lint
errors there.

## Troubleshooting
- **Missing symbol after a rename:** stale output. Run `fvm dart run build_runner clean`,
  then build again.
- **`injection.config.dart` missing a registration:** the class lacks its `@injectable` or
  `@LazySingleton(as: ...)` annotation, or the abstract type in `as:` is wrong.
- **Asset getter not found:** the directory isn't declared under `flutter: assets:` in
  `pubspec.yaml`, or it's listed in the `flutter_gen` exclude block.
- **Very slow or stuck build:** run `make clean` (or `fvm flutter clean && fvm flutter pub get`),
  then rebuild.
