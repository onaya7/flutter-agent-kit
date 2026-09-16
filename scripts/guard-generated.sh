#!/usr/bin/env bash
# PreToolUse: deny edits to Dart codegen output; the annotated source is what must change.
set -uo pipefail

root="${CLAUDE_PROJECT_DIR:-$PWD}"
[ -f "$root/pubspec.yaml" ] || exit 0
command -v jq >/dev/null 2>&1 || exit 0

file=$(jq -r '.tool_input.file_path // empty')
[ -z "$file" ] && exit 0

prefix=""
[ -f "$root/.fvmrc" ] && prefix="fvm "

case "$file" in
  */lib/l10n/gen/*)
    fix="${prefix}flutter gen-l10n" ;;
  *.g.dart|*.freezed.dart|*.config.dart|*.gen.dart)
    fix="${prefix}dart run build_runner build" ;;
  *)
    exit 0 ;;
esac

jq -n --arg f "$file" --arg fix "$fix" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "deny",
    permissionDecisionReason: ($f + " is generated and will be overwritten. Edit the source instead, then run: " + $fix)
  }
}'
