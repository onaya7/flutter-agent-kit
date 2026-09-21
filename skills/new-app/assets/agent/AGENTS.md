# Kit Template App — agent guide

This Flutter app was created from onaya7's flutter-agent-kit; `.kit.json` records the kit commit.
Follow these conventions unless a task explicitly says otherwise.

## Toolchain
- Flutter is pinned with FVM (`.fvmrc`). **Prefix every `dart` and `flutter` command with `fvm`.**
- Run the app through the makefile, not raw flutter: `make run-dev`, `make run-staging`,
  `make run-prod`. `make help` lists the build targets.
- Codegen (freezed, json_serializable, retrofit, injectable, hive, flutter_gen):
  `fvm dart run build_runner build`
- Localization is a **separate** command: `fvm flutter gen-l10n` (configured in `l10n.yaml`).
- Lints: `fvm flutter analyze` **and** `fvm dart run bloc_tools:bloc lint .`. `flutter analyze`
  does not run the bloc_lint rules. CI runs both.
- Tests: `fvm flutter test`.

## Never hand-edit generated files
`*.g.dart`, `*.freezed.dart`, `*.config.dart`, `*.gen.dart` and `lib/l10n/gen/`. Change the
annotated source and rerun codegen. Which outputs are committed is not uniform; see
`.claude/rules/generated-code.md`.

## Architecture: the boundaries that matter
Clean Architecture (`data`/`domain`/`presentation`) with flutter_bloc, get_it + injectable, Dio +
Retrofit, freezed + json_serializable, go_router, Hive CE + flutter_secure_storage, and three flavors
(development, staging, production).

- `domain/` imports no Flutter. A `data/models/` DTO is what the repository, usecase and cubit
  all pass around; `domain/entities/` is for what the wire has no row for.
- Presentation calls a **usecase**, never a repository directly.
- Blocs and cubits never import Flutter (`avoid_flutter_imports`). Use framework-agnostic types and
  convert at the widget boundary.
- `lib/core/services/*` are full clean-architecture sub-features, not a utils folder; the same
  boundaries apply.
- A feature may be presentation-only when its data comes from `lib/core/services/*`.
- **Never import one feature's internals from another.** Promote the shared piece to `core/`.

## Secrets
`.env.development`, `.env.staging` and `.env.production` are committed and shipped inside the app
bundle. Only client-restricted keys belong there, never a server-side secret. Signing material
(`android/key.properties`, `*.jks`, service-account JSON) stays untracked. Tokens, credentials and
personal data go in `SecureLocalDataStorage`, never in Hive.

## Comments: one line, default to none
This applies to code and tests alike. Explain *why* when it is non-obvious; never restate *what*.
A comment that doesn't fit on one line is too long. Views carry no comments. Never reference a
design-tool node; describe the widget by its purpose.

## Before writing new code
- Check `lib/core/components/` for an existing shared widget.
- Check `lib/core/helpers/ui_helpers.dart` before writing navigation, pickers, toasts or dialogs.
- Background reading, on demand: `docs/ARCHITECTURE.md` for system-wide mechanics,
  `docs/features/<feature>.md` for one feature.

## Rules by path: read the rule before editing matching files
Claude Code loads these automatically; other agents must open them.

| When you edit | Read |
|---|---|
| anything in `lib/` or `test/` | `.claude/rules/comments.md` |
| `lib/features/*/data/**`, `lib/features/*/domain/**`, `lib/core/services/**`, `lib/core/network_info/**`, `lib/core/injections/**` | `.claude/rules/data-layer.md` |
| blocs, cubits, `*_state.dart`, `app_bloc_provider.dart` | `.claude/rules/state-management.md` |
| `lib/config/navigators/**`, views, widgets | `.claude/rules/navigation.md` |
| `lib/**/presentation/**`, `lib/core/components/**` | `.claude/rules/ui-conventions.md` |
| `lib/features/**` | `.claude/rules/feature-docs.md` |
| generated output, `lib/gen/**`, `lib/l10n/**`, `pubspec.yaml`, `analysis_options.yaml` | `.claude/rules/generated-code.md` |

## Skills
These come from the kit and are installed per agent, not stored in this repo:
- `add-feature`
- `add-route`
- `setup-go-router`
- `paginate-list`
- `add-picker-sheet`
- `codegen`
- `ship-flavor`
- `sync-app`
- `update-kit`

## Git
Conventional Commits. Pull requests target `development`; CI runs on `development`, `staging` and
`production`.

## Keeping this file current
When you establish a reusable pattern, shared component, convention or load-bearing architectural
fact, record it in the narrowest place that fits: a `.claude/rules/` file if it is path-specific,
this file only if every session needs it. Keep entries to one line with a source path, and delete
anything that becomes wrong. Never add a directory listing or a class inventory. If every future
app should get the change, use the `update-kit` skill as well.
