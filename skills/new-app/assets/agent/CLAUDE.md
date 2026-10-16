@AGENTS.md

## Claude Code
- Rules in `.claude/rules/` load automatically when you touch matching paths; the rule index in
  AGENTS.md exists for other agents.
- The flutter-kit plugin's hooks block edits to generated files, format Dart on write and flag
  stale feature docs.
- The plugin's review agents run as `flutter-kit:code-scanner`, `flutter-kit:refactor-scanner` and
  `flutter-kit:ui-reviewer`; agents only this app needs go in `.claude/agents/`.
