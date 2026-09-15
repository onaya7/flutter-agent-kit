import 'dart:developer';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:kit_template_app/app/presentation/view/app_hive_adapters.dart';
import 'package:kit_template_app/config/flavor/flavor_config.dart';
import 'package:kit_template_app/core/injections/injection.dart';

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    log('onError(${bloc.runtimeType}, $error, $stackTrace)');
    super.onError(bloc, error, stackTrace);
  }
}

/// Step order is load-bearing; insert new steps between the existing ones.
abstract class AppManager {
  AppManager._();

  static Future<void> initialize(FlavorConfig config) async {
    _ensureBindings();
    _wireErrorHandlers();
    await _lockPortrait();
    await _loadEnv(config);
    await _openStorage(config);
    _registerFlavor(config);
    await _configureDependencies();
    _installBlocObserver();
  }

  static void _ensureBindings() {
    WidgetsFlutterBinding.ensureInitialized();
  }

  static void _wireErrorHandlers() {
    FlutterError.onError = (details) {
      log(details.exceptionAsString(), stackTrace: details.stack);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      log('PlatformDispatcher uncaught', error: error, stackTrace: stack);
      return true;
    };
  }

  static Future<void> _lockPortrait() {
    return SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  static Future<void> _loadEnv(FlavorConfig config) {
    return dotenv.load(fileName: config.envFile);
  }

  static Future<void> _openStorage(FlavorConfig config) async {
    await Hive.initFlutter();
    await registerHiveAdapters();
    await Hive.openBox<dynamic>(config.hiveBoxName);
  }

  static void _registerFlavor(FlavorConfig config) {
    if (!sl.isRegistered<FlavorConfig>()) {
      sl.registerSingleton<FlavorConfig>(config);
    }
  }

  static Future<void> _configureDependencies() => configureDependencies();

  static void _installBlocObserver() {
    Bloc.observer = const AppBlocObserver();
  }
}
