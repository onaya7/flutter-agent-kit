import 'package:flutter_test/flutter_test.dart';
import 'package:kit_template_app/app/presentation/bloc/app_bloc.dart';
import 'package:kit_template_app/config/flavor/flavor.dart';
import 'package:kit_template_app/config/flavor/flavor_config.dart';
import 'package:kit_template_app/config/navigators/routes_generator.dart';
import 'package:kit_template_app/core/local_data/local_data_storage.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/helpers.dart';

class _MockLocalDataStorage extends Mock implements LocalDataStorage {}

void main() {
  testWidgets('opens on home and switches to settings from the tab bar', (
    tester,
  ) async {
    final storage = _MockLocalDataStorage();
    when(() => storage.read<String>(any())).thenReturn(null);
    final appBloc = AppBloc(storage);
    addTearDown(appBloc.close);
    final router = AppRouter.create(
      const FlavorConfig(
        flavor: Flavor.development,
        envFile: '.env.development',
        hiveBoxName: 'test_box',
      ),
    );
    addTearDown(router.dispose);

    await tester.pumpApp(null, router: router, appBloc: appBloc);
    await tester.pumpAndSettle();

    expect(find.text('Welcome'), findsOneWidget);
    expect(find.text('Theme'), findsNothing);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Theme'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('Welcome'), findsNothing);
  });
}
