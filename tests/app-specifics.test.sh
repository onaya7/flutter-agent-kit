#!/usr/bin/env bash
# Fails when one app's facts leak into the shared kit.
set -uo pipefail
source "$(dirname "$0")/lib.sh"

# Prose and config only: the base app is real Dart whose package names legitimately
# contain some of these words, and tests/ carries them as literals.
scope=("$kit/AGENTS.md" "$kit/README.md" "$kit/hooks" "$kit/scripts" "$kit/skills/new-app/assets/agent")
scope+=("$kit"/skills/*/SKILL.md)

identity='[Dd]ocalla|com\.docalla|goquays|[Ff]igma|Freshchat'
symbols='ProDashboardCubit|JobEventsNotifier|SafetyMenuButton|runSafetyActionFlow|ConnectionSafetyCubit|LocationSyncPolicy|SwipeCardDeck|kSkipPaywall|_requireSessionId'
release='beta_dev|beta_staging|FIREBASE_APP_ID|APPLE_ID_(DEV|STAGING|PROD)|DEV_GROUP'
structure='lib/features/(my_jobs|browse_jobs|crosspath|travel|connection|home)/|[0-9]+ warnings|8784F1|share_plus'

for group in identity symbols release structure; do
  check "no app-specific $group" empty "$(grep -rniE "${!group}" "${scope[@]}" 2>/dev/null | head -5)"
done

exit "$fail"
