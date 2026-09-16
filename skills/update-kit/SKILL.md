---
name: update-kit
description: Capture a reusable pattern, component, convention, dependency or fix from the current Flutter app into onaya7's flutter-agent-kit, so every future app starts with it. Use when the user says "add this to the kit", "update the kit" or "update the workspace", or wants something to become the default for new apps.
---

# Update the kit

The kit is the git repo `onaya7/flutter-agent-kit`. Installed copies of it are caches that get
overwritten, so always edit the clone.

## 1. Open the clone
Use the first of these that exists:
1. `$FLUTTER_KIT_DIR`
2. `~/Desktop/flutter_projects/flutter-agent-kit`

If neither exists, run `gh repo clone onaya7/flutter-agent-kit ~/Desktop/flutter_projects/flutter-agent-kit`.

In the clone, `git status` must be clean and `git pull --ff-only` must succeed. Otherwise stop and
tell the user; never stash, reset or overwrite their work.

Read the clone's `AGENTS.md` before editing. Its rules and its "Where things live" table govern
every step below.

## 2. Pin down what to capture
Say in one sentence what will change and which files in the current app it comes from. If the
request is vague ("add what we did today"), list candidates from the app's `git log` and `git diff`
and ask which ones.

## 3. Choose where it goes

| It is | Put it in |
|---|---|
| A procedure with steps | An existing skill, or a new `skills/<name>/SKILL.md` |
| A convention for certain paths | A rule template under `skills/new-app/assets/`, plus its line in the AGENTS.md template's rule index |
| A fact every session needs | The AGENTS.md template under `skills/new-app/assets/` |
| Reusable code (widget, helper, core class) | The base app under `skills/new-app/assets/` |
| A dependency, lint or build setting | The base app's `pubspec.yaml`, `analysis_options.yaml` or `makefile` |
| Something Claude Code must be blocked from doing | `hooks/hooks.json` and `scripts/`, plus the same rule in the AGENTS.md template |
| How the kit itself works | The kit's `AGENTS.md` |

Code that only makes sense with an optional module (Firebase, push notifications, maps and so on)
goes in that module, not the base.

## 4. Generalize
- Strip the app's name, endpoints, brand colors, bundle IDs, copy and design-tool references. Use
  the placeholders from `skills/new-app/SKILL.md`.
- Code must compile in a freshly scaffolded app: no imports from `lib/features/`, and no dependency
  on a module the base app doesn't include.
- Search the clone for every skill and template that mentions what you changed, and update them
  together.

## 5. Validate
From the clone:

```sh
claude plugin validate .                 # when the claude CLI is installed
bash -n scripts/*.sh skills/*/scripts/*.sh
for t in tests/*.test.sh; do "$t" || exit 1; done
skills/new-app/scripts/smoke-test.sh
```

The smoke test scaffolds a throwaway app and runs analyze, bloc lint and tests. Fix every failure.
Never skip it for a change to code or templates.

## 6. Commit, then ask before pushing
Show the user a short summary of the diff, then commit with a conventional message
(`feat(base): add PhoneNumberField`). **Ask before running `git push`.**

## 7. Tell the user how the change arrives
- **Claude Code, skills-folder install:** `git -C ~/.claude/skills/flutter-kit pull`, or nothing at
  all when that path is a symlink to this clone.
- **Claude Code, marketplace install:** automatic when auto-update is on for `flutter-agent-kit`;
  otherwise `/plugin marketplace update flutter-agent-kit`, then `/reload-plugins`.
- **Other agents:** `npx skills update -g`.
- **Apps created earlier** keep their own copies of `AGENTS.md`, rules and base code. Offer to run
  the `sync-app` skill in them.
