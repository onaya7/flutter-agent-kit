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

tpl="skills/new-app/assets/template"
excludes=()

# The app's toolchain is the app's decision. Compare the live pins rather than
# .kit.json so this is right for an app that predates the toolchain field, and
# so an unreadable pin counts as divergence: git apply would move an app to the
# kit's Flutter with nobody deciding to.
kit_flutter="$(git -C "$kit" show "HEAD:$tpl/.fvmrc" 2>/dev/null \
  | sed -n 's/.*"flutter"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1 || true)"
app_flutter="$(sed -n 's/.*"flutter"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' \
  "$app/.fvmrc" 2>/dev/null | head -1 || true)"

if [ -z "$app_flutter" ] || [ "$app_flutter" != "$kit_flutter" ]; then
  excludes+=(
    ":(exclude,top)$tpl/.fvmrc"
    ":(exclude,top)$tpl/pubspec.yaml"
    ":(exclude,top)$tpl/pubspec.lock"
    ":(exclude,top)$tpl/.metadata"
    ":(exclude,glob,top)$tpl/.github/**"
    ":(exclude,glob,top)$tpl/android/**.gradle.kts"
    ":(exclude,top)$tpl/android/gradle/wrapper/gradle-wrapper.properties"
    ":(exclude,top)$tpl/ios/Podfile"
  )
fi

# `makefile` and an app's `Makefile` are one path on a case-insensitive
# filesystem. Ask git's index, which distinguishes them, not the filesystem.
if ! git -C "$app" ls-files --error-unmatch makefile >/dev/null 2>&1; then
  excludes+=( ":(exclude,top)$tpl/makefile" )
fi

# Capability gates: probe the app first, fall back to .kit.json only when there
# is nothing on disk to probe.
has() {
  case "$1" in
    l10n)      [ -f "$app/l10n.yaml" ] && return 0 ;;
    bloc_lint) grep -qE '^[[:space:]]+bloc_lint:' "$app/pubspec.yaml" 2>/dev/null && return 0 ;;
  esac
  jq -e --arg k "$1" '(.toolchain.has // []) | index($k)' "$app/.kit.json" >/dev/null 2>&1
}
has l10n      || excludes+=( ":(exclude,top)$tpl/l10n.yaml" ":(exclude,glob,top)$tpl/lib/l10n/**" )
has bloc_lint || excludes+=( ":(exclude,top)$tpl/analysis_options.yaml" )

if [ ${#excludes[@]} -ne 0 ]; then
  {
    echo "Not patched — report these as text (sync-app step 3a):"
    printf '%s\n' "${excludes[@]}" | sed "s|^:(exclude[^)]*)$tpl/|  |"
  } >&2
fi

for r in $roots; do
  git -C "$kit" diff --binary --relative="$r/" "$from" HEAD -- "$r/" \
    ${excludes[@]+"${excludes[@]}"}
done | "$kit/skills/new-app/scripts/rename.sh" filter "$name" "$title" "$app_id"
