#!/usr/bin/env bash
# Prints an app's .kit.json "toolchain" object, read from that app's own files.
# A value it cannot read is null: absent means unknown, never "the kit's".
set -euo pipefail

[ $# -eq 1 ] || { echo "Usage: toolchain.sh <app_dir>" >&2; exit 2; }
app="$(cd "$1" && pwd -P)"

j() { if [ -n "${1:-}" ]; then printf '"%s"' "$1"; else printf 'null'; fi; }

flutter=""
if [ -f "$app/.fvmrc" ]; then
  flutter="$(sed -n 's/.*"flutter"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$app/.fvmrc" | head -1)"
fi

# The lower bound of `environment: sdk:` is the language contract flutter analyze
# enforces; "^3.13.0" and ">=3.0.0 <4.0.0" both reduce to their first X.Y.Z.
dart=""
if [ -f "$app/pubspec.yaml" ]; then
  dart="$(sed -n '/^environment:/,/^[^[:space:]#]/p' "$app/pubspec.yaml" \
    | sed -n 's/^[[:space:]]*sdk:[[:space:]]*//p' \
    | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || true)"
fi

runner=""
if [ -f "$app/.fvmrc" ]; then runner="fvm"; fi

has=""
add() { has="${has:+$has, }\"$1\""; }
if [ -f "$app/l10n.yaml" ]; then add l10n; fi
if [ -f "$app/pubspec.yaml" ] && grep -qE '^[[:space:]]+bloc_lint:' "$app/pubspec.yaml"; then
  add bloc_lint
fi
if [ -d "$app/.github/workflows" ]; then add ci; fi

printf '{\n    "flutter": %s,\n    "dart": %s,\n    "runner": %s,\n    "has": [%s]\n  }' \
  "$(j "$flutter")" "$(j "$dart")" "$(j "$runner")" "$has"
