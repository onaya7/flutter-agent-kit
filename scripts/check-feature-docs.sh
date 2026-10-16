#!/usr/bin/env bash
# Stop: warn when a feature changed but its doc under docs/features/ did not. Never blocks.
set -uo pipefail

cd "${CLAUDE_PROJECT_DIR:-$PWD}" 2>/dev/null || exit 0
[ -f pubspec.yaml ] && [ -d docs/features ] || exit 0
command -v git >/dev/null 2>&1 && command -v jq >/dev/null 2>&1 || exit 0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

# -uall stops git collapsing a new docs/ directory into a single entry.
changed=$(git status --porcelain -uall 2>/dev/null | cut -c4- | sed 's/.* -> //')
[ -z "$changed" ] && exit 0

# A vN/ segment is a version folder, so lib/features/v2/kyc/ maps to docs/features/v2/kyc.md.
features=$(printf '%s\n' "$changed" | sed -nE 's#^lib/features/((v[0-9]+/)?[a-z0-9_]+)/.*#\1#p' \
  | grep -vE '^v[0-9]+$|(^|/)shared$' | sort -u)
[ -z "$features" ] && exit 0

stale=""
while IFS= read -r f; do
  [ -z "$f" ] && continue
  printf '%s\n' "$changed" | grep -qE "^docs/features/(${f}\.md|${f}/.*\.md)$" && continue
  stale="${stale}  lib/features/${f}/ -> docs/features/${f}.md (or docs/features/${f}/*.md)"$'\n'
done <<< "$features"

[ -z "$stale" ] && exit 0
printf '%s' "$stale" | jq -Rs '{systemMessage: ("Feature docs may be stale:\n" + . + "\nUpdate only if purpose, entry screens, endpoints, state or gotchas changed.")}'
