part of 'app_bloc.dart';

@freezed
sealed class AppEvent with _$AppEvent {
  const factory AppEvent.themeChanged(AppThemeMode mode) = AppThemeChanged;
  const factory AppEvent.localeChanged(String languageCode) = AppLocaleChanged;
}
