#!/usr/bin/env bash
# Runs each hook script against throwaway Flutter and non-Flutter folders.
set -uo pipefail
source "$(dirname "$0")/lib.sh"

app="$tmp/app"
plain="$tmp/plain"
mkdir -p "$app/lib/features/orders" "$app/docs/features" "$plain/lib"
touch "$app/pubspec.yaml" "$app/.fvmrc"

guard() { printf '{"tool_input":{"file_path":"%s"}}' "$2" | CLAUDE_PROJECT_DIR="$1" "$kit/scripts/guard-generated.sh"; }
check "guard denies *.g.dart" match "$(guard "$app" "$app/lib/a.g.dart")" '"deny"'
check "guard names build_runner for freezed" match "$(guard "$app" "$app/lib/a.freezed.dart")" 'fvm dart run build_runner'
check "guard names gen-l10n for l10n output" match "$(guard "$app" "$app/lib/l10n/gen/app_localizations.dart")" 'fvm flutter gen-l10n'
check "guard allows hand-written Dart" empty "$(guard "$app" "$app/lib/main.dart")"
check "guard ignores non-Flutter folders" empty "$(guard "$plain" "$plain/lib/a.g.dart")"

fmt_app="$tmp/fmt"
mkdir -p "$fmt_app/lib"
touch "$fmt_app/pubspec.yaml"
if command -v dart >/dev/null 2>&1; then
  printf "void main(){print('x');}\n" > "$fmt_app/lib/main.dart"
  printf '{"tool_input":{"file_path":"%s"}}' "$fmt_app/lib/main.dart" | CLAUDE_PROJECT_DIR="$fmt_app" "$kit/scripts/format-dart.sh"
  check "format rewrites written Dart" match "$(cat "$fmt_app/lib/main.dart")" 'void main() {'
  printf "void main(){print('x');}\n" > "$fmt_app/lib/main.g.dart"
  printf '{"tool_input":{"file_path":"%s"}}' "$fmt_app/lib/main.g.dart" | CLAUDE_PROJECT_DIR="$fmt_app" "$kit/scripts/format-dart.sh"
  check "format leaves generated Dart alone" match "$(cat "$fmt_app/lib/main.g.dart")" 'void main(){'
else
  echo "skip format checks: dart not on PATH"
fi

docs() { (cd "$1" && CLAUDE_PROJECT_DIR="$1" "$kit/scripts/check-feature-docs.sh"); }
git -C "$app" init -q
echo x > "$app/lib/features/orders/orders_view.dart"
check "docs warns when a feature changed without its doc" match "$(docs "$app")" 'docs/features/orders'
echo "# Orders" > "$app/docs/features/orders.md"
check "docs is quiet once the doc changed" empty "$(docs "$app")"
mkdir -p "$app/lib/features/home" "$app/docs/features/home"
echo x > "$app/lib/features/home/home_view.dart"
echo x > "$app/docs/features/home/jobs.md"
check "docs accepts a doc split into a folder" empty "$(docs "$app")"
mkdir -p "$app/lib/features/v2/kyc" "$app/lib/features/v2/shared" "$app/docs/features/v2"
echo x > "$app/lib/features/v2/kyc/kyc_view.dart"
check "docs maps a versioned feature to its own doc" match "$(docs "$app")" 'docs/features/v2/kyc.md'
echo x > "$app/docs/features/v2/invest.md"
check "docs is not silenced by another versioned doc" match "$(docs "$app")" 'docs/features/v2/kyc.md'
echo "# KYC" > "$app/docs/features/v2/kyc.md"
echo x > "$app/lib/features/v2/shared/money.dart"
echo x > "$app/lib/features/v2/v2_app.dart"
check "docs skips shared and the version folder itself" empty "$(docs "$app")"
check "docs ignores non-Flutter folders" empty "$(docs "$plain")"

exit "$fail"
