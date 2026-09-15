import 'package:flutter_test/flutter_test.dart';
import 'package:kit_template_app/app/presentation/bloc/app_bloc.dart';
import 'package:kit_template_app/core/local_data/local_data_storage.dart';
import 'package:kit_template_app/features/settings/presentation/view/settings_view.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/helpers.dart';

class _MockLocalDataStorage extends Mock implements LocalDataStorage {}

void main() {
  late _MockLocalDataStorage storage;
  late AppBloc appBloc;

  setUp(() {
    storage = _MockLocalDataStorage();
    when(() => storage.read<String>(any())).thenReturn(null);
    when(() => storage.write<String>(any(), any())).thenAnswer((_) async {});
    appBloc = AppBloc(storage);
  });

  tearDown(() => appBloc.close());

  testWidgets('choosing a theme updates AppBloc', (tester) async {
    await tester.pumpApp(const SettingsView(), appBloc: appBloc);

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect(appBloc.state, const AppState.ready(themeMode: AppThemeMode.dark));
  });

  testWidgets('choosing a language updates AppBloc', (tester) async {
    await tester.pumpApp(const SettingsView(), appBloc: appBloc);

    await tester.tap(find.text('Español'));
    await tester.pumpAndSettle();

    expect(appBloc.state, const AppState.ready(languageCode: 'es'));
  });
}
