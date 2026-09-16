import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kit_template_app/config/theme/app_theme_colors.dart';
import 'package:kit_template_app/core/components/radio_dot.dart';

import '../../helpers/helpers.dart';

void main() {
  Future<void> pump(WidgetTester tester, {required bool selected}) =>
      tester.pumpApp(
        Scaffold(
          body: Center(child: RadioDot(selected: selected)),
        ),
      );

  BoxDecoration outerDecoration(WidgetTester tester) =>
      tester
              .widget<Container>(
                find
                    .descendant(
                      of: find.byType(RadioDot),
                      matching: find.byType(Container),
                    )
                    .first,
              )
              .decoration!
          as BoxDecoration;

  testWidgets('unselected is an empty ring', (tester) async {
    await pump(tester, selected: false);

    final decoration = outerDecoration(tester);
    expect(decoration.color, isNull);
    expect(decoration.shape, BoxShape.circle);
    expect(
      (decoration.border! as Border).top.color,
      AppThemeColors.light.fill,
    );
    expect(tester.getSize(find.byType(RadioDot)), const Size(22, 22));
  });

  testWidgets('selected fills with the primary and shows an inner dot', (
    tester,
  ) async {
    await pump(tester, selected: true);

    expect(outerDecoration(tester).color, AppThemeColors.light.primary);
    expect(find.byType(DecoratedBox), findsWidgets);
    expect(tester.getSize(find.byType(RadioDot)), const Size(20, 20));
  });

  testWidgets('follows the dark palette', (tester) async {
    await tester.pumpApp(
      const Scaffold(body: Center(child: RadioDot(selected: true))),
      themeMode: ThemeMode.dark,
    );

    expect(outerDecoration(tester).color, AppThemeColors.dark.primary);
  });
}
