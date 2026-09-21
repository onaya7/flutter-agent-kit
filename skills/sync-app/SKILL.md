---
name: sync-app
description: Bring a Flutter app created from onaya7's flutter-agent-kit up to date with later kit changes to its base code, AGENTS.md, rules, Claude settings and module files. Use when the user asks to sync, refresh or upgrade an app to the latest kit, or after update-kit when older apps should get a change.
---

# Sync an app with the kit

Run from the app's root. Skills and hooks update on their own. This skill brings over what
`new-app` copied into the app: base code, `AGENTS.md`, `.claude/rules/`, `.claude/settings.json`
and module files.

## 1. Check the app
- `.kit.json` must exist at the app root. If it doesn't, the app wasn't created by the kit; use the
  `adopt-app` skill instead.
- `git status` must be clean so the sync can be reviewed on its own. If it isn't, ask the user to
  commit or stash; never do either for them.

## 2. Open the kit clone
Follow step 1 of the `update-kit` skill, and call the clone's path `$KIT`. Installed copies of the
kit have no git history, so the clone is required.

## 3. Build the patch
```sh
patch="$(mktemp)"
"$KIT/skills/sync-app/scripts/kit-patch.sh" . > "$patch"
```
- **Exit code 3** means `kit_commit` in `.kit.json` is unknown to the clone. Go to step 6.
- **Empty output** means there is nothing to sync. Record the commit (step 5) and stop.

For context, read `git -C "$KIT" log --oneline <kit_commit>..HEAD`. For each module listed in
`.kit.json`, also diff `skills/new-app/assets/modules/<module>/apply.sh` over the same range.
Changes there, such as a new dependency, have to be carried over by hand.

## 3a. Toolchain files are reported, not patched
`kit-patch.sh` leaves out every file that pins a Flutter or Dart version, a dependency floor, or CI
wiring, and prints the list it dropped to stderr. `git apply` would move the app's toolchain with
nobody deciding to. Read them as text instead and carry over only what the user approves:

```sh
tpl=skills/new-app/assets/template
git -C "$KIT" diff "$(jq -r .kit_commit .kit.json)" HEAD -- \
  "$tpl/pubspec.yaml" "$tpl/.fvmrc" "$tpl/pubspec.lock" "$tpl/makefile" \
  "$tpl/analysis_options.yaml" "$tpl/l10n.yaml" "$tpl/.github/"
```

**`pubspec.yaml` is the one that matters.** `update-kit` routes every new kit dependency there, so a
new package reaches this app only through this diff. Add each one with
`fvm flutter pub add <package>`, which picks a version this app's SDK can resolve. Never copy the
kit's constraint or its `environment:` block — both assume the kit's Flutter.

A Flutter or Dart bump is a separate decision with its own blast radius: CI, Podfile, Gradle, and
anything that must move in lockstep with `.fvmrc` (check AGENTS.md). Report it; never apply it as
part of a sync.

## 4. Review and apply
1. Show the user `git apply --stat "$patch"` and the kit log, grouped into base code, agent files
   and modules. Ask which groups to take.
2. Apply the chosen parts, for example `git apply --3way --include='lib/core/*' "$patch"`.
3. Resolve conflicts by keeping the app's intentional changes and adding the kit's improvement on
   top. Ask when the intent is unclear.
4. App-specific facts already in `AGENTS.md` or `.claude/rules/` always win over template wording.
5. `docs/ARCHITECTURE.md` describes the kit's stack. If a hunk there states a version or a tool this
   app does not have, correct it to the app's own facts rather than taking the kit's wording.

## 5. Verify and record
```sh
fvm flutter gen-l10n   # only if .kit.json toolchain.has lists l10n
fvm dart run build_runner build
fvm dart fix --apply --code=directives_ordering   # renamed kit imports sort differently per app
fvm dart format lib test
fvm flutter analyze
fvm dart run bloc_tools:bloc lint .   # only if .kit.json toolchain.has lists bloc_lint
fvm flutter test
```
Fix anything the sync broke. Then set `kit_commit` in `.kit.json` to the output of
`git -C "$KIT" rev-parse HEAD`.

Then reconcile the `toolchain` block:

```sh
now="$("$KIT/skills/new-app/scripts/toolchain.sh" .)"
was="$(jq -c '.toolchain // null' .kit.json)"
```

- `was` is `null` — the app predates this field. Write `now` in; nothing is lost.
- They match — nothing to do.
- They differ — **do not write.** Show the user both and name the cause: either the sync added a
  capability they accepted from the step 3a diff, or the app's toolchain drifted since the last sync
  and `.kit.json` has been stale ever since. Only the first is a reason to move the baseline.

```sh
jq --argjson t "$now" '.toolchain = $t' .kit.json > .kit.json.tmp && mv .kit.json.tmp .kit.json
```

Leave the changes uncommitted unless the user asks for a commit.

## 6. When kit_commit is unknown
Scaffold a reference copy using the names in `.kit.json`, then compare:

```sh
ref="$(mktemp -d)/ref"
"$KIT/skills/new-app/scripts/create-app.sh" --name <app_name> --title "<title>" --org <org> \
  --app-id <app_id> --dir "$ref" --skip-setup   # add --modules <a,b> if .kit.json lists any
diff -ru --exclude=.git --exclude=build --exclude=.dart_tool --exclude=.kit.json "$ref" .
```

Treat every difference as a suggestion, not a patch; most of them are the app's own features.
Bring over only what the user approves, then continue at step 5.
