---
name: new-app
description: Create a new Flutter app from onaya7's flutter-agent-kit — FVM-pinned Flutter, development/staging/production flavors, clean architecture with bloc, DI, networking, theming, routing, tests and CI already wired, plus AGENTS.md, path-scoped rules and Claude Code settings. Use when the user wants to start, create, scaffold or set up a new Flutter app or project.
---

# Create a new app

## 1. Settle the names, asking once
Propose values from what the user already said, then confirm all of them in one message:

| Value | Rule | Example |
|---|---|---|
| App name (Dart package) | snake_case | `field_notes` |
| Display name | Letters, digits, spaces and hyphens; max 30 | `Field Notes` |
| Organisation | Reverse domain | `com.onaya7` |
| Bundle / application ID | Default `<org>.<app name without underscores>`; lowercase dot-separated segments, no `_` or `-` | `com.onaya7.fieldnotes` |
| Folder | Default `./<app name>`; use the current folder if it's empty | `~/Desktop/flutter_projects/field_notes` |
| Modules | Optional; list `assets/modules/` next to this file. Skip the question if it's empty | |

## 2. Check prerequisites
`fvm`, `git` and `jq` must be on `PATH`. Xcode and the Android SDK are needed only to build and run,
not to create the app.

## 3. Create it
`<skill-dir>` is the folder containing this SKILL.md. In Claude Code it's `${CLAUDE_SKILL_DIR}`.

```sh
"<skill-dir>/scripts/create-app.sh" --name field_notes --title "Field Notes" --org com.onaya7 \
  --dir ~/Desktop/flutter_projects/field_notes   # optional: --app-id <id>, --modules <a,b>
```

The script:
1. Copies the base app and agent files.
2. Applies the chosen modules.
3. Replaces the template's placeholder names.
4. Writes `.kit.json`.
5. Runs `git init`, `fvm install`, `pub get`, `gen-l10n` and `build_runner`.

It refuses a folder that isn't empty.

## 4. Verify
In the new app:

```sh
fvm flutter analyze
fvm dart run bloc_tools:bloc lint .
fvm flutter test
```

All three must pass before you report success. A failure in a fresh app is a kit bug. Fix it in the
app so the user isn't blocked, tell them, and suggest the `update-kit` skill to fix the template.

## 5. Hand over
Tell the user what they got:
- A running base app: home and settings tabs, three flavors, and `make help`.
- `AGENTS.md` for every agent, `CLAUDE.md`, `.claude/rules/`, `.claude/settings.json` and
  `.kit.json`.

Then list what's left for them:
1. Fill in `.env.development`, `.env.staging` and `.env.production`; `.env.example` lists the keys.
2. Replace the palette in `lib/core/constants/app_color.dart` and
   `lib/config/theme/app_theme_colors.dart`, then update the pinned values in the theme test.
3. Replace `assets/images/appicon.png`, then run `fvm dart run flutter_launcher_icons` and
   `fvm dart run flutter_native_splash:create`.
4. Set the iOS development team in Xcode.
5. Fill in `context/project-overview.md` with the product, flavors and branches. The `feature`
   skill reads it on every task.

Also:
- Recommend the official Flutter plugin for generic Flutter skills and the Dart MCP server. Claude
  Code prompts for it from `.claude/settings.json`. Other agents run
  `npx skills add flutter/agent-plugins --skill '*' --agent universal -y`.
- Ask whether to make the first commit. Don't commit unasked.

## Template reference, for kit maintainers

| Path next to this file | Contents |
|---|---|
| `assets/template/` | The base app, a normal compilable Flutter app using the placeholders below |
| `assets/agent/` | `AGENTS.md`, `CLAUDE.md`, `.claude/rules/`, `.claude/settings.json` and the `context/` workflow files for the new app |
| `assets/modules/<name>/` | `apply.sh <app_dir>`, plus an optional `files/` overlay that `sync-app` tracks |
| `scripts/` | `create-app.sh`, `rename.sh` and `smoke-test.sh` |

`scripts/rename.sh` replaces these placeholders:

| Placeholder | Becomes |
|---|---|
| `kit_template_app` | Dart package name |
| `Kit Template App` | Display name |
| `com.example.kittemplate` | Bundle / application ID |
| `com/example/kittemplate` | Kotlin package path |

To change the template, work inside `assets/template/` like any app: `fvm flutter pub get`, codegen,
analyze, test. Generated files and build output there are gitignored and never copied into new
apps. Then run `scripts/smoke-test.sh` (with `SMOKE_BUILD=1` for native or dependency changes).
