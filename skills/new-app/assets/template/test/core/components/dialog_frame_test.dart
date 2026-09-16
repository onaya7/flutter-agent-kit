import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kit_template_app/config/theme/app_theme_colors.dart';
import 'package:kit_template_app/core/components/dialog_frame.dart';

import '../../helpers/helpers.dart';

void main() {
  testWidgets('stacks its children on a card-coloured surface', (tester) async {
    await tester.pumpApp(
      const Scaffold(
        body: DialogFrame(children: [Text('Title'), Text('Body')]),
      ),
    );

    expect(find.text('Title'), findsOneWidget);
    expect(find.text('Body'), findsOneWidget);
    expect(
      tester.widget<Dialog>(find.byType(Dialog)).backgroundColor,
      AppThemeColors.light.cards,
    );
  });

  testWidgets('takes the dark card colour in dark mode', (tester) async {
    await tester.pumpApp(
      const Scaffold(body: DialogFrame(children: [Text('Title')])),
      themeMode: ThemeMode.dark,
    );

    expect(
      tester.widget<Dialog>(find.byType(Dialog)).backgroundColor,
      AppThemeColors.dark.cards,
    );
  });

  testWidgets('shrink-wraps an empty child list', (tester) async {
    await tester.pumpApp(const Scaffold(body: DialogFrame(children: [])));

    expect(tester.takeException(), isNull);
    expect(find.byType(Dialog), findsOneWidget);
  });
}
