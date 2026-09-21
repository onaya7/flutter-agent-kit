#!/usr/bin/env bash
# Builds a new app from the kit: copy template and agent files, apply modules, rename, fetch packages, generate code.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
assets="${KIT_ASSETS:-$here/../assets}"

# Build output and generated code in a working copy of the template must never reach a new app.
copy_tree() {
  (cd "$1" && tar -cf - \
    --exclude .dart_tool --exclude build --exclude .fvm --exclude Pods --exclude .symlinks \
    --exclude .gradle --exclude ephemeral --exclude local.properties --exclude Generated.xcconfig \
    --exclude flutter_export_environment.sh --exclude .flutter-plugins \
    --exclude .flutter-plugins-dependencies --exclude ./lib/l10n/gen \
    --exclude '*.g.dart' --exclude '*.freezed.dart' --exclude '*.config.dart' --exclude '*.gen.dart' \
    --exclude .DS_Store --exclude '*.iml' --exclude 'GeneratedPluginRegistrant.*' \
    --exclude ./.vscode/settings.json .) | (cd "$2" && tar -xf -)
}

usage() {
  cat >&2 <<'EOF'
Usage: create-app.sh --name <package_name> --title "<Display Name>" --org <reverse.domain> [options]

  --name        Dart package name in snake_case, e.g. field_notes
  --title       Display name: letters, digits, spaces and hyphens, max 30
  --org         Reverse-domain organisation, e.g. com.onaya7
  --app-id      Bundle and application ID (default: <org>.<name without underscores>)
  --dir         Target folder (default: ./<name>); an empty existing folder is fine
  --modules     Comma-separated optional modules from assets/modules/
  --skip-setup  Copy and rename only; skip fvm install, pub get and codegen
EOF
  exit 2
}

name="" title="" org="" app_id="" dir="" modules="" skip_setup=false
while [ $# -gt 0 ]; do
  case "$1" in
    --name) [ $# -ge 2 ] || usage; name="$2"; shift 2 ;;
    --title) [ $# -ge 2 ] || usage; title="$2"; shift 2 ;;
    --org) [ $# -ge 2 ] || usage; org="$2"; shift 2 ;;
    --app-id) [ $# -ge 2 ] || usage; app_id="$2"; shift 2 ;;
    --dir) [ $# -ge 2 ] || usage; dir="$2"; shift 2 ;;
    --modules) [ $# -ge 2 ] || usage; modules="$2"; shift 2 ;;
    --skip-setup) skip_setup=true; shift ;;
    -h|--help) usage ;;
    *) echo "Unknown option: $1" >&2; usage ;;
  esac
done

[ -n "$name" ] && [ -n "$title" ] && [ -n "$org" ] || usage
[ -n "$app_id" ] || app_id="$org.${name//_/}"
[ -n "$dir" ] || dir="$PWD/$name"
"$here/rename.sh" check "$name" "$title" "$app_id"
[ -d "$assets/template" ] || { echo "Template missing: $assets/template" >&2; exit 1; }

# Editor and agent folders appear as soon as a session opens in an empty directory.
if [ -d "$dir" ] && ls -A "$dir" | grep -qvxE '\.claude|\.git|\.DS_Store|\.idea|\.vscode'; then
  echo "$dir is not empty" >&2; exit 1
fi

if [ -n "$modules" ]; then
  IFS=',' read -r -a module_list <<< "$modules"
  for m in "${module_list[@]}"; do
    [ -x "$assets/modules/$m/apply.sh" ] || { echo "Unknown module: $m (see $assets/modules/)" >&2; exit 1; }
  done
fi

mkdir -p "$dir"
dir="$(cd "$dir" && pwd -P)"
copy_tree "$assets/template" "$dir"
copy_tree "$assets/agent" "$dir"

if [ -n "$modules" ]; then
  for m in "${module_list[@]}"; do
    "$assets/modules/$m/apply.sh" "$dir"
  done
fi

"$here/rename.sh" apply "$dir" "$name" "$title" "$app_id"

kit_root="$(cd "$here/../../.." && pwd -P)"
kit_commit="unknown"
if [ -f "$kit_root/.claude-plugin/marketplace.json" ] \
  && [ "$(git -C "$kit_root" rev-parse --show-toplevel 2>/dev/null)" = "$kit_root" ]; then
  kit_commit="$(git -C "$kit_root" rev-parse --verify -q HEAD 2>/dev/null)" || kit_commit="unknown"
fi

modules_json=""
if [ -n "$modules" ]; then
  for m in "${module_list[@]}"; do
    modules_json="${modules_json:+$modules_json, }\"$m\""
  done
fi
# Read $dir, not the template: modules have already run and may have added a
# capability, and the app is what this block describes.
toolchain_json="$("$here/toolchain.sh" "$dir")"

cat > "$dir/.kit.json" <<EOF
{
  "kit_commit": "$kit_commit",
  "created": "$(date +%Y-%m-%d)",
  "app_name": "$name",
  "title": "$title",
  "org": "$org",
  "app_id": "$app_id",
  "modules": [$modules_json],
  "toolchain": $toolchain_json
}
EOF

[ -d "$dir/.git" ] || git -C "$dir" init -q -b main

if [ "$skip_setup" = false ]; then
  command -v fvm >/dev/null 2>&1 || { echo "fvm is required: https://fvm.app" >&2; exit 1; }
  cd "$dir"
  fvm install
  fvm flutter pub get
  fvm flutter gen-l10n
  fvm dart run build_runner build
  # The new package name changes where the app's own imports sort among third-party ones.
  fvm dart fix --apply --code=directives_ordering
  fvm dart format lib test >/dev/null
fi

echo "Created $title ($app_id) at $dir"
