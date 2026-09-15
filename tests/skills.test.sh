#!/usr/bin/env bash
# Checks every SKILL.md against the Agent Skills frontmatter rules so any agent can load it.
set -uo pipefail
source "$(dirname "$0")/lib.sh"

for f in "$kit"/skills/*/SKILL.md; do
  dir="$(basename "$(dirname "$f")")"
  front="$(awk 'NR == 1 { next } $0 == "---" { exit } { print }' "$f")"
  name="$(printf '%s\n' "$front" | sed -n 's/^name: *//p')"
  desc="$(printf '%s\n' "$front" | sed -n 's/^description: *//p')"
  len=${#desc}

  check "$dir: opens with frontmatter" match "$(head -1 "$f")" '^---$'
  check "$dir: name matches its folder" match "$name" "^$dir\$"
  check "$dir: name is lowercase letters, digits and hyphens" match "$name" '^[a-z0-9][a-z0-9-]*[a-z0-9]$'
  check "$dir: name has no double hyphen" empty "$(printf '%s' "$name" | grep -- '--')"
  check "$dir: description is 1-1024 characters" match "$([ "$len" -ge 1 ] && [ "$len" -le 1024 ] && echo ok || echo "length $len")" '^ok$'
  check "$dir: description has no ': ' that breaks unquoted YAML" empty "$(printf '%s' "$desc" | grep ': ')"
  check "$dir: body stays under 500 lines" match "$([ "$(wc -l < "$f")" -lt 500 ] && echo ok || echo long)" '^ok$'
done

exit "$fail"
