import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kit_template_app/app/presentation/bloc/app_bloc.dart';
import 'package:kit_template_app/config/theme/app_theme.dart';
import 'package:kit_template_app/l10n/l10n.dart';

extension PumpApp on WidgetTester {
  /// Pumps [widget], or [router] when given, under the app themes and l10n.
  Future<void> pumpApp(
    Widget? widget, {
    GoRouter? router,
    ThemeMode themeMode = ThemeMode.light,
    Locale? locale,
    AppBloc? appBloc,
  }) {
    assert(
      (widget == null) != (router == null),
      'Pass either a widget or a router',
    );
    final app = router == null
        ? MaterialApp(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: widget,
          )
        : MaterialApp.router(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: router,
          );
    return pumpWidget(
      appBloc == null
          ? app
          : BlocProvider<AppBloc>.value(value: appBloc, child: app),
    );
  }
}
