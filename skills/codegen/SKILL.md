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
| `lib/l10n/arb/*.arb` | `fvm flutter gen-l10n` — **only if this app has localization** |

`build_runner` does **not** generate localization, and `gen-l10n` generates nothing else.

Not every app has every generator. Before running `gen-l10n`, check
`jq -r '.toolchain.has[]?' .kit.json` lists `l10n`, or that `l10n.yaml` exists. No `l10n.yaml` means
this app has no localization — do not create one as a side effect of a codegen task. Drop the `fvm`
prefix if `jq -r '.toolchain.runner // "fvm"' .kit.json` is not `fvm`.

## Stale output
Run `fvm dart run build_runner build`. If it stops on a conflicting-outputs error, re-run with
`--delete-conflicting-outputs`: that flag is **required** before build_runner 2.16 and is accepted
but ignored on 2.16+, so it is safe at every version. `fvm dart run build_runner clean` is the hard
reset.

`--keep-modified-outputs` (keep hand edits to generated files) and `--only-check` (CI: build,
compare against disk, write nothing, fail on any difference) are **2.16+ only** — older versions
abort with a usage error. `pubspec.lock` is the only thing that knows the resolved version:

```sh
awk '$1=="build_runner:"{f=1} f && /version:/{print $2; exit}' pubspec.lock
```

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
