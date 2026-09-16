import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kit_template_app/config/theme/app_theme_colors.dart';
import 'package:kit_template_app/core/components/field_label.dart';

import '../../helpers/helpers.dart';

void main() {
  TextStyle styleOf(WidgetTester tester) =>
      tester.widget<Text>(find.byType(Text)).style!;

  testWidgets('renders heading-coloured text at the default weight', (
    tester,
  ) async {
    await tester.pumpApp(const Scaffold(body: FieldLabel('Email address')));

    expect(find.text('Email address'), findsOneWidget);
    expect(styleOf(tester).color, AppThemeColors.light.textHeading);
    expect(styleOf(tester).fontSize, 16);
    expect(styleOf(tester).fontWeight, FontWeight.w500);
  });

  testWidgets('honours an overridden size and weight', (tester) async {
    await tester.pumpApp(
      const Scaffold(
        body: FieldLabel('Section', fontSize: 20, fontWeight: FontWeight.w700),
      ),
    );

    expect(styleOf(tester).fontSize, 20);
    expect(styleOf(tester).fontWeight, FontWeight.w700);
  });

  testWidgets('follows the dark heading colour', (tester) async {
    await tester.pumpApp(
      const Scaffold(body: FieldLabel('Email address')),
      themeMode: ThemeMode.dark,
    );

    expect(styleOf(tester).color, AppThemeColors.dark.textHeading);
  });
}
