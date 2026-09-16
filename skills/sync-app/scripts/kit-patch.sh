#!/usr/bin/env bash
# Prints the kit's template changes since an app's recorded kit commit, renamed for that app, as a git patch.
set -euo pipefail

[ $# -eq 1 ] || { echo "Usage: kit-patch.sh <app_dir>" >&2; exit 2; }
command -v jq >/dev/null 2>&1 || { echo "jq is required" >&2; exit 1; }

app="$(cd "$1" && pwd -P)"
kit="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd -P)"

if [ ! -f "$kit/.claude-plugin/marketplace.json" ] \
  || [ "$(git -C "$kit" rev-parse --show-toplevel 2>/dev/null)" != "$kit" ]; then
  echo "Run this script from a git clone of flutter-agent-kit, not an installed copy" >&2; exit 1
fi
# A clone's own origin ref can be stale too, so fetch before trusting the comparison.
git -C "$kit" fetch -q origin 2>/dev/null || true
behind="$(git -C "$kit" rev-list --count HEAD..origin/main 2>/dev/null || echo 0)"
[ "$behind" -eq 0 ] || {
  echo "This kit clone is $behind commits behind origin/main; run: git -C $kit pull --ff-only" >&2
  exit 1
}

[ -f "$app/.kit.json" ] || { echo "$app has no .kit.json; use the adopt-app skill" >&2; exit 1; }

from="$(jq -r '.kit_commit' "$app/.kit.json")"
if ! git -C "$kit" cat-file -e "${from}^{commit}" 2>/dev/null; then
  echo "kit_commit '$from' is not in the clone; compare against a fresh scaffold instead" >&2; exit 3
fi

name="$(jq -r '.app_name' "$app/.kit.json")"
title="$(jq -r '.title' "$app/.kit.json")"
app_id="$(jq -r '.app_id' "$app/.kit.json")"

roots="skills/new-app/assets/template skills/new-app/assets/agent"
for m in $(jq -r '.modules[]?' "$app/.kit.json"); do
  roots="$roots skills/new-app/assets/modules/$m/files"
done

for r in $roots; do
  git -C "$kit" diff --binary --relative="$r/" "$from" HEAD -- "$r/"
done | "$kit/skills/new-app/scripts/rename.sh" filter "$name" "$title" "$app_id"
