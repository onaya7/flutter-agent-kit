---
name: adopt-app
description: Bring an existing Flutter app that was not created from onaya7's flutter-agent-kit onto the kit, with AGENTS.md, path-scoped rules, Claude settings and a .kit.json baseline for future syncs, and report how its base code differs from the kit's. Use when the user wants an older app to follow the kit or to receive kit updates.
---

# Adopt an existing app

The goal is a shared agent setup and a baseline for future syncs, not a rewrite. Never restructure
the app's code as part of adoption.

## 1. Preconditions
- Run from the app root, where `pubspec.yaml` lives.
- `git status` must be clean. Otherwise ask the user to commit or stash first.
- Open the kit clone as in step 1 of the `update-kit` skill, and call its path `$KIT`.

## 2. Identify the app
| Value | Where to find it |
|---|---|
| `app_name` | `name:` in `pubspec.yaml` |
| `app_id` | `applicationId` in `android/app/build.gradle.kts` or `build.gradle`, without a flavor suffix |
| `org` | `app_id` without its last segment |
| `title` | The production app name in the flavor setup |
| `modules` | Kit modules (`ls "$KIT/skills/new-app/assets/modules"`) the app already has an equivalent of |

Confirm these values with the user.

## 3. Scaffold a reference copy
```sh
ref="$(mktemp -d)/ref"
"$KIT/skills/new-app/scripts/create-app.sh" --name <app_name> --title "<title>" --org <org> \
  --app-id <app_id> --dir "$ref" --skip-setup   # add --modules <a,b> when the app has any
```
If `app_id` fails validation (for example it contains underscores), pass a close valid value. The
reference copy only guides the comparison.

## 4. Agent files
- **AGENTS.md:** start from `$ref/AGENTS.md`. Carry over every fact that is still true, checked
  against the code, from the app's existing `CLAUDE.md`, `AGENTS.md`, `GEMINI.md`, `.cursor/rules/`
  or `.github/copilot-instructions.md`. Move path-specific conventions into
  `.claude/rules/<topic>.md` with `paths:` frontmatter, and list each one in the AGENTS.md rule
  index.
- **CLAUDE.md:** once its content lives in AGENTS.md or rules, replace it with `$ref/CLAUDE.md`.
- **.claude/settings.json:** merge `$ref/.claude/settings.json` into the existing file. Keep the
  app's own permissions. Remove inline hooks the flutter-kit plugin already provides: the
  generated-file guard, Dart formatting and the feature-doc check. Never touch
  `settings.local.json`.
- **context/:** copy `$ref/context/`. Fill `project-overview.md` from facts verified in the app
  (README, docs, flavors, branches) and link to existing docs rather than repeating them. Move any
  in-flight plan or handoff the user keeps elsewhere into `context/features/`, list its open items
  under Notes in `current-feature.md`, and summarize shipped work under History.
- **Local skills** in `.claude/skills/` that duplicate a kit skill: move anything app-specific into
  a rule, then delete the local copy so the kit's version is the only one. The same goes for local
  agents in `.claude/agents/` that duplicate a kit agent; keep only app-specific ones.
- Anything that would help every app is a candidate for `update-kit`. List those for the user
  instead of editing the kit during adoption.

## 5. Report base-code differences
```sh
diff -rq --exclude=.git --exclude=build --exclude=.dart_tool "$ref/lib" lib
```
Group the report into:
- kit concepts the app implements under another name
- kit pieces the app lacks
- app pieces that look reusable (candidates for `update-kit`)

Don't change code. Offer migrations one at a time.

## 6. Record the baseline and verify
Copy `$ref/.kit.json` to the app root, then **overwrite every value it inherited from the kit**.
`$ref` is a fresh kit scaffold, so its `toolchain` block describes the *kit's* Flutter, Dart and
tooling — not this app's. Leaving it is worse than leaving it out: later skills branch on those
numbers and would be confidently wrong.

```sh
cp "$ref/.kit.json" .kit.json
jq --arg c "$(git -C "$KIT" rev-parse HEAD)" \
   --argjson t "$("$KIT/skills/new-app/scripts/toolchain.sh" .)" \
   '.kit_commit = $c | .adopted = true | .toolchain = $t' \
   .kit.json > .kit.json.tmp && mv .kit.json.tmp .kit.json
```

`toolchain.sh` must run against `.`, the app root, never `$ref`. Check before moving on — these two
must print the same version:

```sh
jq -r '.toolchain.flutter' .kit.json
jq -r '.flutter' .fvmrc
```

Then mirror the same facts into AGENTS.md's Toolchain section in prose, derived from `.kit.json` and
never the reverse: the Flutter version, the run/codegen/test commands, and anything that must move
in lockstep with `.fvmrc` (a `SHOREBIRD_FLUTTER` makefile variable, for instance). Lockstep pairs
belong in AGENTS.md, not in `.kit.json`.

Run the app's analyze and tests. Leave the changes uncommitted unless the user asks for a commit.
