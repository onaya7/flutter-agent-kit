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

## 4. Review and apply
1. Show the user `git apply --stat "$patch"` and the kit log, grouped into base code, agent files
   and modules. Ask which groups to take.
2. Apply the chosen parts, for example `git apply --3way --include='lib/core/*' "$patch"`.
3. Resolve conflicts by keeping the app's intentional changes and adding the kit's improvement on
   top. Ask when the intent is unclear.
4. App-specific facts already in `AGENTS.md` or `.claude/rules/` always win over template wording.

## 5. Verify and record
```sh
fvm flutter gen-l10n
fvm dart run build_runner build --delete-conflicting-outputs
fvm dart fix --apply --code=directives_ordering   # renamed kit imports sort differently per app
fvm dart format lib test
fvm flutter analyze
fvm dart run bloc_tools:bloc lint .
fvm flutter test
```
Fix anything the sync broke. Then set `kit_commit` in `.kit.json` to the output of
`git -C "$KIT" rev-parse HEAD`. Leave the changes uncommitted unless the user asks for a commit.

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
