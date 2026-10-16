# review

1. Read `context/current-feature.md` and its spec for the goals and the phases done so far.
2. Read the whole diff: `git diff development...HEAD` plus uncommitted changes.
3. Report under these headings:
   - ✅ **Goals met**
   - ❌ **Goals missing or incomplete**
   - ⚠️ **Bugs and risks**: `BuildContext` used after an `await` without the right `mounted`
     check, controllers, focus nodes, timers or stream subscriptions never disposed, a cubit that
     emits after `close`, unhandled `Left`/failure paths, null assertions on server data
   - ⚠️ **Boundaries**: a view or cubit calling a repository, `domain/` importing `data/` or
     Flutter, a cubit importing Flutter, one feature importing another's internals
   - ⚠️ **Conventions**: hard-coded colours, sizes, asset strings or copy where `AGENTS.md` names
     a source; hand-edited generated files; comments the comment rule forbids
   - ⚠️ **Tests**: new cubits, usecases and screens without tests, or goldens the app expects
   - ⚠️ **Docs**: `docs/features/<feature>.md` or `AGENTS.md` now wrong after this change
   - 🚫 **Scope creep**: code no goal asks for
4. Give each finding a file and line. End with a verdict: ready to complete, or the list to fix.
5. In Claude Code, the flutter-kit `code-scanner` and `ui-reviewer` agents go deeper when the user
   asks for a full audit.
