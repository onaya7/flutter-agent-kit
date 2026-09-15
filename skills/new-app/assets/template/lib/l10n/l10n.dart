import 'package:flutter/widgets.dart';
import 'package:kit_template_app/l10n/gen/app_localizations.dart';

export 'package:kit_template_app/l10n/gen/app_localizations.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
