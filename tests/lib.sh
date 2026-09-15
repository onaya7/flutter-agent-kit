#!/usr/bin/env bash
# Shared assertions for the kit's shell tests; sourced, never run directly.

kit="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
fail=0

check() {
  local name="$1" expect="$2" out="$3" pattern="${4:-}"
  if [ "$expect" = empty ]; then
    if [ -z "$out" ]; then echo "ok   $name"; else echo "FAIL $name: expected no output, got: $out"; fail=1; fi
  elif printf '%s' "$out" | grep -q -- "$pattern"; then
    echo "ok   $name"
  else
    echo "FAIL $name: expected /$pattern/, got: $out"; fail=1
  fi
}
