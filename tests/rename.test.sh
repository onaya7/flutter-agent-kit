#!/usr/bin/env bash
# Runs rename.sh against a miniature template tree and a patch stream.
set -uo pipefail
source "$(dirname "$0")/lib.sh"

rename="$kit/skills/new-app/scripts/rename.sh"
t="$tmp/app"
kt="android/app/src/main/kotlin"
mkdir -p "$t/lib" "$t/$kt/com/example/kittemplate" "$t/ios/Runner.xcodeproj" "$t/assets"
printf 'name: kit_template_app\n' > "$t/pubspec.yaml"
printf "import 'package:kit_template_app/app/app.dart';\n" > "$t/lib/main.dart"
printf 'applicationId = "com.example.kittemplate"\nresValue("string", "app_name", "[DEV] Kit Template App")\n' > "$t/android/app/build.gradle.kts"
printf 'package com.example.kittemplate\n' > "$t/$kt/com/example/kittemplate/MainActivity.kt"
printf 'PRODUCT_BUNDLE_IDENTIFIER = com.example.kittemplate.dev;\n' > "$t/ios/Runner.xcodeproj/project.pbxproj"
printf '\x89PNG\x00kit_template_app\x00' > "$t/assets/icon.png"
icon_before="$(shasum "$t/assets/icon.png" | cut -d' ' -f1)"

"$rename" apply "$t" field_notes "Field Notes" com.onaya7.fieldnotes
check "renames the pubspec package" match "$(cat "$t/pubspec.yaml")" 'name: field_notes'
check "renames Dart package imports" match "$(cat "$t/lib/main.dart")" 'package:field_notes/app/app.dart'
check "renames the Android application id" match "$(cat "$t/android/app/build.gradle.kts")" '"com.onaya7.fieldnotes"'
check "renames the display name" match "$(cat "$t/android/app/build.gradle.kts")" '\[DEV\] Field Notes'
check "renames the iOS bundle id" match "$(cat "$t/ios/Runner.xcodeproj/project.pbxproj")" 'com.onaya7.fieldnotes.dev'
check "moves the Kotlin package folder" match "$(cat "$t/$kt/com/onaya7/fieldnotes/MainActivity.kt" 2>&1)" 'package com.onaya7.fieldnotes'
check "removes the old Kotlin folders" empty "$(ls -d "$t/$kt/com/example" 2>/dev/null)"
check "leaves binary files untouched" match "$(shasum "$t/assets/icon.png" | cut -d' ' -f1)" "$icon_before"

check "rejects an app id with underscores" match "$("$rename" check field_notes "Field Notes" com.onaya7.field_notes 2>&1)" 'app_id must'
check "rejects a title with punctuation" match "$("$rename" check field_notes "Field's Notes" com.onaya7.fieldnotes 2>&1)" 'title may'
check "rejects names containing a placeholder" match "$("$rename" check kit_template_app_two "X" com.onaya7.x 2>&1)" 'placeholders'

patch_out="$(printf '+++ b/%s/com/example/kittemplate/X.kt\n+name: kit_template_app\n' "$kt" \
  | "$rename" filter field_notes "Field Notes" com.onaya7.fieldnotes)"
check "filter renames patch paths" match "$patch_out" 'com/onaya7/fieldnotes/X.kt'
check "filter renames patch content" match "$patch_out" '+name: field_notes'

exit "$fail"
