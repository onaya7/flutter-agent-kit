#!/usr/bin/env bash
# PostToolUse: format each Dart file an agent writes, using the FVM-pinned SDK when the app has one.
set -uo pipefail

root="${CLAUDE_PROJECT_DIR:-$PWD}"
[ -f "$root/pubspec.yaml" ] || exit 0
command -v jq >/dev/null 2>&1 || exit 0

file=$(jq -r '.tool_response.filePath // .tool_input.file_path // empty')
case "$file" in
  *.g.dart|*.freezed.dart|*.config.dart|*.gen.dart) exit 0 ;;
  *.dart) ;;
  *) exit 0 ;;
esac

if [ -f "$root/.fvmrc" ] && command -v fvm >/dev/null 2>&1; then
  (cd "$root" && fvm dart format "$file") >/dev/null 2>&1
elif command -v dart >/dev/null 2>&1; then
  dart format "$file" >/dev/null 2>&1
fi
exit 0
