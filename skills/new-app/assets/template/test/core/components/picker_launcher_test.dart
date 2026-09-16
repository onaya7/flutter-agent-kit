import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kit_template_app/config/theme/app_theme_colors.dart';
import 'package:kit_template_app/core/components/picker_launcher.dart';

import '../../helpers/helpers.dart';

void main() {
  Future<void> pump(
    WidgetTester tester, {
    String? value,
    Widget? leading,
    Widget? trailing,
    VoidCallback? onTap,
  }) => tester.pumpApp(
    Scaffold(
      body: Center(
        child: PickerLauncher(
          value: value,
          placeholder: 'Choose one',
          leading: leading,
          trailing: trailing,
          onTap: onTap ?? () {},
        ),
      ),
    ),
  );

  TextStyle styleOf(WidgetTester tester, String text) =>
      tester.widget<Text>(find.text(text)).style!;

  testWidgets('shows the placeholder in the subtext colour', (tester) async {
    await pump(tester);

    expect(find.text('Choose one'), findsOneWidget);
    expect(styleOf(tester, 'Choose one').color, AppThemeColors.light.subtext);
    expect(styleOf(tester, 'Choose one').fontWeight, FontWeight.w400);
  });

  testWidgets('a value replaces the placeholder and reads as heading', (
    tester,
  ) async {
    await pump(tester, value: 'Weekly');

    expect(find.text('Choose one'), findsNothing);
    expect(styleOf(tester, 'Weekly').color, AppThemeColors.light.textHeading);
    expect(styleOf(tester, 'Weekly').fontWeight, FontWeight.w500);
  });

  testWidgets('leading and trailing slots are rendered', (tester) async {
    await pump(
      tester,
      value: 'Weekly',
      leading: const Icon(Icons.calendar_today),
      trailing: const Icon(Icons.expand_more),
    );

    expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    expect(find.byIcon(Icons.expand_more), findsOneWidget);
  });

  testWidgets('omits the trailing slot when none is given', (tester) async {
    await pump(tester, value: 'Weekly');

    expect(find.byIcon(Icons.expand_more), findsNothing);
  });

  testWidgets('tapping opens the picker', (tester) async {
    var taps = 0;
    await pump(tester, onTap: () => taps++);

    await tester.tap(find.byType(PickerLauncher));
    await tester.pumpAndSettle();
    expect(taps, 1);
  });
}
