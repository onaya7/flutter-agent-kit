#!/usr/bin/env bash
# Swaps the template's placeholder identifiers for a real app's, in a folder or in a patch stream.
set -euo pipefail

SENTINEL_NAME="kit_template_app"
SENTINEL_TITLE="Kit Template App"
SENTINEL_ID="com.example.kittemplate"
SENTINEL_PATH="com/example/kittemplate"

name_re='^[a-z][a-z0-9_]*$'
title_re='^[A-Za-z0-9][A-Za-z0-9 -]{0,29}$'
id_re='^[a-z][a-z0-9]*(\.[a-z][a-z0-9]*)+$'

usage() {
  cat >&2 <<'EOF'
Usage: rename.sh check  <app_name> <title> <app_id>
       rename.sh apply  <dir> <app_name> <title> <app_id>
       rename.sh filter <app_name> <title> <app_id>    (reads stdin, writes stdout)
EOF
  exit 2
}

validate() {
  [ $# -eq 3 ] || usage
  [[ "$1" =~ $name_re ]] || { echo "app_name must be snake_case: $1" >&2; exit 2; }
  [[ "$2" =~ $title_re ]] || { echo "title may use letters, digits, spaces and hyphens, max 30: $2" >&2; exit 2; }
  [[ "$3" =~ $id_re ]] || { echo "app_id must be lowercase dot-separated segments without underscores or hyphens: $3" >&2; exit 2; }
  case "$1|$2|$3" in
    *kittemplate*|*kit_template_app*|*"Kit Template App"*)
      echo "names must not contain the template's placeholders" >&2; exit 2 ;;
  esac
  export S_NAME="$SENTINEL_NAME" S_TITLE="$SENTINEL_TITLE" S_ID="$SENTINEL_ID" S_PATH="$SENTINEL_PATH"
  export APP_NAME="$1" APP_TITLE="$2" APP_ID="$3"
  APP_PATH="$(printf '%s' "$3" | tr . /)"
  export APP_PATH
}

# The dotted id is replaced before the bare package name so neither rewrites the other.
subst='
  s{\Q$ENV{S_ID}\E}{$ENV{APP_ID}}g;
  s{\Q$ENV{S_PATH}\E}{$ENV{APP_PATH}}g;
  s{\Q$ENV{S_NAME}\E}{$ENV{APP_NAME}}g;
  s{\Q$ENV{S_TITLE}\E}{$ENV{APP_TITLE}}g;
'
pattern='kit_template_app|Kit Template App|com\.example\.kittemplate|com/example/kittemplate'

files_with_placeholders() {
  grep -rIlE "$pattern" "$1" --exclude-dir=.git --exclude-dir=build --exclude-dir=.dart_tool || true
}

apply() {
  local dir="$1"; shift
  [ -d "$dir" ] || { echo "No such folder: $dir" >&2; exit 2; }
  validate "$@"

  while IFS= read -r f; do
    [ -n "$f" ] && perl -pi -e "$subst" "$f"
  done <<< "$(files_with_placeholders "$dir")"

  while IFS= read -r d; do
    [ -z "$d" ] && continue
    local base="${d%/"$SENTINEL_PATH"}"
    mkdir -p "$(dirname "$base/$APP_PATH")"
    mv "$d" "$base/$APP_PATH"
    find "$base" -type d -empty -delete
  done <<< "$(find "$dir" -type d -path "*/$SENTINEL_PATH" -not -path '*/build/*' -not -path '*/.git/*')"

  local left
  left="$(files_with_placeholders "$dir")"
  [ -z "$left" ] || { printf 'Placeholders left in:\n%s\n' "$left" >&2; exit 1; }
}

[ $# -ge 1 ] || usage
mode="$1"; shift
case "$mode" in
  check) validate "$@" ;;
  apply) [ $# -eq 4 ] || usage; apply "$@" ;;
  filter) validate "$@"; perl -pe "$subst" ;;
  *) usage ;;
esac
