import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kit_template_app/config/theme/app_theme_colors.dart';
import 'package:kit_template_app/core/components/sheet_handle.dart';

import '../../helpers/helpers.dart';

void main() {
  BoxDecoration barDecoration(WidgetTester tester) =>
      tester
              .widget<Container>(
                find.descendant(
                  of: find.byType(SheetHandle),
                  matching: find.byType(Container),
                ),
              )
              .decoration!
          as BoxDecoration;

  testWidgets('draws a centred 40x5 bar', (tester) async {
    await tester.pumpApp(const Scaffold(body: SheetHandle()));

    expect(
      tester.getSize(
        find.descendant(
          of: find.byType(SheetHandle),
          matching: find.byType(Container),
        ),
      ),
      const Size(40, 5),
    );
    expect(find.byType(Center), findsWidgets);
  });

  testWidgets('takes the light fill colour', (tester) async {
    await tester.pumpApp(const Scaffold(body: SheetHandle()));
    expect(barDecoration(tester).color, AppThemeColors.light.fill);
  });

  testWidgets('takes the dark fill colour', (tester) async {
    await tester.pumpApp(
      const Scaffold(body: SheetHandle()),
      themeMode: ThemeMode.dark,
    );
    expect(barDecoration(tester).color, AppThemeColors.dark.fill);
  });
}
