---
name: cleanup
description: Find housekeeping debt in a flutter-agent-kit app (stray prints, dead files and assets, unexplained ignores, hard-coded colours, drifted context and docs) and fix only the items the user picks. Use when the user asks to clean up, tidy or audit housekeeping, with check to report or run to fix.
---

# Cleanup

Run from the app's root. Mode is the argument: `check` (the default) only reports; `run` reports,
then fixes the items the user chooses.

## What to look for

Read `AGENTS.md` first. Where it names its own source of truth (a colour file, a logger, an asset
class, a frozen folder), check against that. Skip any folder `AGENTS.md` marks frozen unless the
user names it.

1. **History order**: `## History` in `context/current-feature.md` runs oldest to newest.
2. **Logging**: `print(` and `debugPrint(` under `lib/`; the app logs through its logger.
3. **Dead code**: run `fvm flutter analyze` for unused imports and elements. Then find Dart files
   under `lib/` that nothing imports (excluding entry points, generated files and `part` files).
4. **Dead assets**: files under `assets/` that neither the generated asset class usages nor a
   string reference reach, and goldens whose test or capture no longer exists.
5. **Ignores and TODOs**: `// ignore:` without a reason on the line above, any
   `ignore_for_file`, and TODOs that point at finished work.
6. **Hard-coded values**: hex colours (`Color(0x`) outside the colour primitives file, raw
   `'assets/` strings, and literal durations or curves where the app has a motion constant.
7. **Docs drift**: `context/project-overview.md`, `docs/ARCHITECTURE.md` and each
   `docs/features/<feature>.md` against the code — features, routes, endpoints and cubits that were
   added, renamed or removed.
8. **Env keys**: every key the env class reads appears in `.env.example`, and `.env.example` has
   no key nothing reads. Say which keys must be set per flavor; never print a value.

## Report

Number every finding, grouped by the headings above, with file and line. Say "nothing found" for an
empty group.

## Mode `run`

1. Report as above, then ask: "Which items should I fix? (numbers like 1,3,5, `all` or `none`)".
2. Wait for the answer. Fix only those items, the smallest change each.
3. Run `fvm flutter analyze` and `fvm flutter test`; report what changed and the result.
4. Never delete a file the user did not pick, and never commit.
