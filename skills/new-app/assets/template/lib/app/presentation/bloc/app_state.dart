part of 'app_bloc.dart';

@freezed
sealed class AppState with _$AppState {
  const factory AppState.initial() = AppInitial;
  const factory AppState.ready({
    @Default(AppThemeMode.system) AppThemeMode themeMode,
    @Default('en') String languageCode,
  }) = AppReady;
}
