import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kit_template_app/app/presentation/bloc/app_bloc.dart';
import 'package:kit_template_app/core/constants/storage_keys.dart';
import 'package:kit_template_app/core/local_data/local_data_storage.dart';

class _MemoryStorage implements LocalDataStorage {
  _MemoryStorage([Map<String, Object?>? values]) : values = {...?values};

  final Map<String, Object?> values;

  @override
  T? read<T>(String key, {T? defaultValue}) {
    final value = values[key];
    return value is T ? value : defaultValue;
  }

  @override
  Future<void> write<T>(String key, T value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);

  @override
  Future<void> clear() async => values.clear();
}

void main() {
  group('AppBloc restores settings synchronously', () {
    test('starts from defaults when nothing is stored', () {
      final bloc = AppBloc(_MemoryStorage());
      addTearDown(bloc.close);

      expect(bloc.state, const AppState.ready());
    });

    test('starts from the stored theme and locale', () {
      final bloc = AppBloc(
        _MemoryStorage({
          StorageKeys.themeMode: AppThemeMode.dark.name,
          StorageKeys.locale: 'es',
        }),
      );
      addTearDown(bloc.close);

      expect(
        bloc.state,
        const AppState.ready(themeMode: AppThemeMode.dark, languageCode: 'es'),
      );
    });

    test('falls back to system for an unknown stored theme', () {
      final bloc = AppBloc(_MemoryStorage({StorageKeys.themeMode: 'sepia'}));
      addTearDown(bloc.close);

      expect(bloc.state, const AppState.ready());
    });
  });

  group('AppBloc persists changes', () {
    late _MemoryStorage storage;

    setUp(() => storage = _MemoryStorage());

    blocTest<AppBloc, AppState>(
      'themeChanged emits the mode and stores its name',
      build: () => AppBloc(storage),
      act: (bloc) => bloc.add(const AppEvent.themeChanged(AppThemeMode.light)),
      expect: () => [const AppState.ready(themeMode: AppThemeMode.light)],
      verify: (_) => expect(storage.values[StorageKeys.themeMode], 'light'),
    );

    blocTest<AppBloc, AppState>(
      'localeChanged emits the language and stores it',
      build: () => AppBloc(storage),
      act: (bloc) => bloc.add(const AppEvent.localeChanged('es')),
      expect: () => [const AppState.ready(languageCode: 'es')],
      verify: (_) => expect(storage.values[StorageKeys.locale], 'es'),
    );

    test('a new bloc over the same storage sees the last changes', () async {
      final first = AppBloc(storage)
        ..add(const AppEvent.themeChanged(AppThemeMode.dark))
        ..add(const AppEvent.localeChanged('es'));
      await first.close();

      final second = AppBloc(storage);
      addTearDown(second.close);

      expect(
        second.state,
        const AppState.ready(themeMode: AppThemeMode.dark, languageCode: 'es'),
      );
    });
  });
}
