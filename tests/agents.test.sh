#!/usr/bin/env bash
# Checks every plugin agent's frontmatter so Claude Code loads it, and that agents stay app-agnostic.
set -uo pipefail
source "$(dirname "$0")/lib.sh"

for f in "$kit"/agents/*.md; do
  file="$(basename "$f" .md)"
  front="$(awk 'NR == 1 { next } $0 == "---" { exit } { print }' "$f")"
  name="$(printf '%s\n' "$front" | sed -n 's/^name: *//p')"

  check "$file: opens with frontmatter" match "$(head -1 "$f")" '^---$'
  check "$file: name matches its file" match "$name" "^$file\$"
  check "$file: has a description" match "$(printf '%s\n' "$front" | sed -n 's/^description: *//p')" '.'
  check "$file: lists its tools" match "$(printf '%s\n' "$front" | sed -n 's/^tools: *//p')" '.'
  check "$file: never writes files" empty "$(printf '%s\n' "$front" | grep -E '^tools:.*\b(Write|Edit)\b')"
done

check "context templates exist" match "$(ls "$kit"/skills/new-app/assets/agent/context/*.md 2>/dev/null | wc -l | tr -d ' ')" '^[3-9]$'

exit "$fail"
