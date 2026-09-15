import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kit_template_app/app/presentation/bloc/app_bloc.dart';
import 'package:kit_template_app/app/presentation/view/app_bloc_provider.dart';
import 'package:kit_template_app/config/flavor/flavor_config.dart';
import 'package:kit_template_app/config/navigators/routes_generator.dart';
import 'package:kit_template_app/config/theme/app_theme.dart';
import 'package:kit_template_app/core/components/app_loader.dart';
import 'package:kit_template_app/core/constants/keys.dart';
import 'package:kit_template_app/core/helpers/keyboard_dismissal.dart';
import 'package:kit_template_app/core/injections/injection.dart';
import 'package:kit_template_app/l10n/l10n.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final GoRouter _router = AppRouter.create(sl<FlavorConfig>());

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  ThemeMode _toThemeMode(AppThemeMode mode) => switch (mode) {
    AppThemeMode.system => ThemeMode.system,
    AppThemeMode.light => ThemeMode.light,
    AppThemeMode.dark => ThemeMode.dark,
  };

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: AppBlocProvider.providers,
      child: BlocBuilder<AppBloc, AppState>(
        builder: (context, state) {
          final themeMode = state.maybeWhen(
            ready: (mode, _) => _toThemeMode(mode),
            orElse: () => ThemeMode.system,
          );
          final locale = state.whenOrNull(ready: (_, code) => Locale(code));
          return MaterialApp.router(
            scaffoldMessengerKey: Keys.scaffoldMessengerKey,
            routerConfig: _router,
            scrollBehavior: KeyboardDismissal.scrollBehavior,
            builder: (context, child) => DevicePreview.appBuilder(
              context,
              Actions(
                actions: KeyboardDismissal.tapOutsideActions,
                child: AppLoaderOverlay(
                  child: child ?? const SizedBox.shrink(),
                ),
              ),
            ),
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            locale: DevicePreview.locale(context) ?? locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
