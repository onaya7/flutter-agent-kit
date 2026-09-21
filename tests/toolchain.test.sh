#!/usr/bin/env bash
# Runs toolchain.sh against hand-built app dirs: version parsing and capability detection.
set -uo pipefail
source "$(dirname "$0")/lib.sh"

tc() { "$kit/skills/new-app/scripts/toolchain.sh" "$1" 2>&1 | tr -d ' \n'; }

# A kit-shaped app: caret constraint, every capability present.
full="$tmp/full"
mkdir -p "$full/.github/workflows"
printf '{\n  "flutter": "3.47.2"\n}' > "$full/.fvmrc"
printf 'environment:\n  sdk: ^3.13.0\n  flutter: ^3.47.0\n\ndev_dependencies:\n  bloc_lint: ^0.3.6\n' > "$full/pubspec.yaml"
touch "$full/l10n.yaml"
check "reads a caret sdk constraint" match "$(tc "$full")" '"dart":"3.13.0"'
check "reads the fvm pin" match "$(tc "$full")" '"flutter":"3.47.2"'
check "detects every capability" match "$(tc "$full")" '"has":\["l10n","bloc_lint","ci"\]'

# An adopted app: ranged constraint, no capabilities.
old="$tmp/old"
mkdir -p "$old"
printf '{\n  "flutter": "3.38.7"\n}' > "$old/.fvmrc"
printf 'environment:\n  sdk: ">=3.0.0 <4.0.0"\n\ndev_dependencies:\n  very_good_analysis: ^10.1.0\n' > "$old/pubspec.yaml"
check "takes the lower bound of a ranged constraint" match "$(tc "$old")" '"dart":"3.0.0"'
check "reports no capabilities" match "$(tc "$old")" '"has":\[\]'
check "ignores a lookalike dependency" empty "$(tc "$old" | grep -o bloc_lint)"

# Nothing readable: every field null rather than the kit's values.
bare="$tmp/bare"
mkdir -p "$bare"
check "reports an unreadable toolchain as null" match "$(tc "$bare")" '"flutter":null,"dart":null,"runner":null,"has":\[\]'

# A flutter version but no pubspec.
half="$tmp/half"
mkdir -p "$half"
printf '{"flutter":"3.41.0"}' > "$half/.fvmrc"
check "reports runner fvm whenever .fvmrc exists" match "$(tc "$half")" '"runner":"fvm"'
check "leaves dart null with no pubspec" match "$(tc "$half")" '"dart":null'

check "emits parseable JSON" match "$("$kit/skills/new-app/scripts/toolchain.sh" "$full" | jq -r '.flutter' 2>&1)" '3.47.2'

exit "$fail"
