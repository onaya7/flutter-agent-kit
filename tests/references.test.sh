#!/usr/bin/env bash
# Fails when a skill, rule or the AGENTS.md template names a path, symbol, make target or env file the template lacks.
set -uo pipefail
source "$(dirname "$0")/lib.sh"

tpl="$kit/skills/new-app/assets/template"
if [ ! -f "$tpl/pubspec.yaml" ]; then
  echo "skip reference checks: no template at $tpl"
  exit 0
fi

docs="$(find "$kit/skills/new-app/assets/agent" -name '*.md'; ls "$kit"/skills/*/SKILL.md)"

# Generated output appears only after codegen; signing files must stay absent; assets/* here names the kit's own folders.
generated='^(lib/gen/|lib/l10n/gen/|android/key\.properties|assets/(template|agent|modules)/)'

paths="$(printf '%s\n' "$docs" | xargs grep -ohE '`(lib|test|docs|assets|android|ios)/[^` ]+`' \
  | tr -d '`' | grep -vE '[<>*{}]' | grep -vE "$generated" | sort -u)"
while IFS= read -r p; do
  [ -z "$p" ] && continue
  check "path exists: $p" match "$([ -e "$tpl/$p" ] && echo ok || echo missing)" '^ok$'
done <<< "$paths"

symbols="AppManager FlavorConfig Flavor AppRouter RoutesName RoutesPath AppExtraCodec hideNavRoutePrefixes
AppTheme AppThemeColors AppColor AppGradient AppSize AppUrl Env StorageKeys AppLinks
Failure AppException ConvertFailureToString UseCase StreamUseCase NoParams InternetSafeRunner EitherSafeRunner
configureDependencies RegisterModule ApiClient LocalDataStorage SecureLocalDataStorage registerHiveAdapters
UiHelpers KeyboardDismissal PhoneCountry Validators AppBloc
CustomScaffold CustomButton CustomInputField InputFieldVariant PhoneNumberField PinnedActionLayout
LoadingIndicator AppErrorState AppEmptyState showFeedbackSheet FeedbackKind NetworkSvgIcon CustomNavigationBar NotFoundView
ToastStatus pumpApp loadTestEnv toE164 toNational openExternalUrl navigateForResult replaceStack showLoader hideLoader datePicker
AppSwitch CountFilterChip FilterPill SelectionChip SegmentedTabBar RadioDot RadioOption RatingStars
SearchBarField PickerLauncher DatePickerField MoneyInputField MoneyInputFormatter FieldLabel
UserAvatar CustomCachedImage AppImageCache GradientText CustomRipple CustomDashedBorderPainter
DialogFrame SheetHandle"
for s in $symbols; do
  check "symbol defined or used: $s" match "$(grep -rlw --include='*.dart' "$s" "$tpl/lib" "$tpl/test" 2>/dev/null | head -1)" '.'
done

roles="textHeading textSubheading subtext textLink background cards cardFill stroke strokeFill fill divider modalSurface icon iconBg iconLow iconInactive primary"
colors="$tpl/lib/config/theme/app_theme_colors.dart"
for r in $roles; do
  check "theme role: $r" match "$(grep -E "final Color $r;" "$colors" 2>/dev/null)" '.'
done

for target in run-dev run-staging run-prod build-dev-apk build-staging-aab build-prod-ipa clean help; do
  check "make target: $target" match "$(grep -E "^$target:" "$tpl/makefile" "$tpl/Makefile" 2>/dev/null)" '.'
done

for f in .env.development .env.staging .env.production .env.example .fvmrc; do
  check "file exists: $f" match "$([ -f "$tpl/$f" ] && echo ok || echo missing)" '^ok$'
done

check "no product names left" empty "$(grep -rliE 'docalla|8784F1' "$tpl" --exclude-dir=.dart_tool --exclude-dir=build --exclude-dir=Pods 2>/dev/null | head -5)"

exit "$fail"
