#!/usr/bin/env bash
# Scaffolds a throwaway app from the kit and proves it analyzes, lints and tests clean.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
modules="${1:-}"
tmp="$(mktemp -d)"
app="$tmp/smoke_app"
trap 'echo "Smoke test failed; the app is left at $app" >&2' ERR

"$here/create-app.sh" --name smoke_app --title "Smoke App" --org com.example.smoke --dir "$app" \
  ${modules:+--modules "$modules"}

cd "$app"
fvm flutter analyze
fvm dart run bloc_tools:bloc lint .
fvm flutter test

if [ "${SMOKE_BUILD:-0}" = 1 ]; then
  fvm flutter build apk --debug --flavor development -t lib/main_development.dart
  fvm flutter build ios --simulator --debug --flavor staging -t lib/main_staging.dart
fi

trap - ERR
rm -rf "$tmp"
echo "Smoke test passed${modules:+ with modules: $modules}"
