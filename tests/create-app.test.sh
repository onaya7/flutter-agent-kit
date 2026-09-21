#!/usr/bin/env bash
# Runs create-app.sh against a miniature template: copy filters, renaming, modules and .kit.json.
set -uo pipefail
source "$(dirname "$0")/lib.sh"

assets="$tmp/assets"
tpl="$assets/template"
mkdir -p "$tpl/lib/l10n/gen" "$tpl/lib/gen" "$tpl/.dart_tool" "$tpl/ios/Pods" "$tpl/ios/Runner" "$tpl/.vscode" "$assets/agent/.claude" "$assets/modules/demo"
printf 'name: kit_template_app\n' > "$tpl/pubspec.yaml"
printf "import 'package:kit_template_app/app.dart';\n" > "$tpl/lib/main.dart"
printf 'part of x;\n' > "$tpl/lib/main.g.dart"
touch "$tpl/lib/l10n/gen/app_localizations.dart" "$tpl/lib/gen/assets.gen.dart" "$tpl/.dart_tool/cache" "$tpl/ios/Pods/x"
touch "$tpl/ios/Runner/GeneratedPluginRegistrant.m" "$tpl/.vscode/settings.json" "$tpl/.vscode/launch.json"
printf '# Kit Template App\n' > "$assets/agent/AGENTS.md"
printf '{}\n' > "$assets/agent/.claude/settings.json"
printf '#!/usr/bin/env bash\ntouch "$1/demo-applied"\n' > "$assets/modules/demo/apply.sh"
chmod +x "$assets/modules/demo/apply.sh"

create() { KIT_ASSETS="$assets" "$kit/skills/new-app/scripts/create-app.sh" --skip-setup "$@" 2>&1; }

app="$tmp/field_notes"
out="$(create --name field_notes --title "Field Notes" --org com.onaya7 --dir "$app" --modules demo)"
check "reports the created app" match "$out" 'Created Field Notes (com.onaya7.fieldnotes)'
check "copies and renames the template" match "$(cat "$app/pubspec.yaml" 2>&1)" 'name: field_notes'
check "copies and renames agent files" match "$(cat "$app/AGENTS.md" 2>&1)" '# Field Notes'
check "copies dot folders" match "$(ls -A "$app/.claude" 2>&1)" 'settings.json'
check "skips generated Dart" empty "$(ls "$app/lib/main.g.dart" "$app/lib/gen/assets.gen.dart" 2>/dev/null)"
check "skips l10n output" empty "$(ls -d "$app/lib/l10n/gen" 2>/dev/null)"
check "skips build caches" empty "$(ls -d "$app/.dart_tool" "$app/ios/Pods" 2>/dev/null)"
check "skips generated plugin registrants and editor settings" empty "$(ls "$app/ios/Runner/GeneratedPluginRegistrant.m" "$app/.vscode/settings.json" 2>/dev/null)"
check "keeps shared launch configs" match "$(ls "$app/.vscode" 2>&1)" 'launch.json'
check "runs module apply scripts" match "$(ls "$app")" 'demo-applied'
check "writes a valid .kit.json" match "$(jq -r '.app_id + " " + (.modules | join(","))' "$app/.kit.json" 2>&1)" 'com.onaya7.fieldnotes demo'
check "records an unknown toolchain as null, never the kit's" match "$(jq -c '.toolchain' "$app/.kit.json" 2>&1)" '{"flutter":null,"dart":null,"runner":null,"has":\[\]}'
check "initialises git" match "$(git -C "$app" rev-parse --is-inside-work-tree 2>&1)" 'true'

check "refuses a non-empty folder" match "$(create --name field_notes --title "Field Notes" --org com.onaya7 --dir "$app")" 'is not empty'
mkdir -p "$tmp/empty/.claude"
check "accepts a folder holding only agent dot folders" match "$(create --name other_app --title "Other" --org com.onaya7 --dir "$tmp/empty")" 'Created Other'
check "rejects unknown modules" match "$(create --name x_app --title "X" --org com.onaya7 --dir "$tmp/x" --modules nope)" 'Unknown module: nope'
check "rejects an invalid package name" match "$(create --name XApp --title "X" --org com.onaya7 --dir "$tmp/y")" 'snake_case'

exit "$fail"
