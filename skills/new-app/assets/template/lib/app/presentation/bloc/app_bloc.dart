import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:kit_template_app/core/constants/storage_keys.dart';
import 'package:kit_template_app/core/local_data/local_data_storage.dart';

part 'app_bloc.freezed.dart';
part 'app_event.dart';
part 'app_state.dart';

enum AppThemeMode { system, light, dark }

/// Owns theme and locale, restored synchronously from storage on launch.
@lazySingleton
class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc(this._storage) : super(_restore(_storage)) {
    on<AppThemeChanged>((event, emit) {
      _updateReady(emit, (current) => current.copyWith(themeMode: event.mode));
      unawaited(_storage.write(StorageKeys.themeMode, event.mode.name));
    });

    on<AppLocaleChanged>((event, emit) {
      _updateReady(
        emit,
        (current) => current.copyWith(languageCode: event.languageCode),
      );
      unawaited(_storage.write(StorageKeys.locale, event.languageCode));
    });
  }

  final LocalDataStorage _storage;

  void _updateReady(
    Emitter<AppState> emit,
    AppReady Function(AppReady current) update,
  ) {
    final current = state;
    emit(update(current is AppReady ? current : const AppReady()));
  }

  static AppState _restore(LocalDataStorage storage) {
    final storedThemeName = storage.read<String>(StorageKeys.themeMode);
    final themeMode = AppThemeMode.values.firstWhere(
      (mode) => mode.name == storedThemeName,
      orElse: () => AppThemeMode.system,
    );
    final languageCode = storage.read<String>(StorageKeys.locale);

    return AppState.ready(
      themeMode: themeMode,
      languageCode: languageCode ?? const AppReady().languageCode,
    );
  }
}
