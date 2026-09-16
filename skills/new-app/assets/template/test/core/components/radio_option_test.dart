import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kit_template_app/core/components/radio_dot.dart';
import 'package:kit_template_app/core/components/radio_option.dart';

import '../../helpers/helpers.dart';

void main() {
  Future<void> pump(
    WidgetTester tester, {
    required bool selected,
    VoidCallback? onTap,
  }) => tester.pumpApp(
    Scaffold(
      body: Center(
        child: RadioOption(
          label: 'Every week',
          selected: selected,
          onTap: onTap ?? () {},
        ),
      ),
    ),
  );

  bool dotIsSelected(WidgetTester tester) =>
      tester.widget<RadioDot>(find.byType(RadioDot)).selected;

  testWidgets('shows the label beside an unselected dot', (tester) async {
    await pump(tester, selected: false);

    expect(find.text('Every week'), findsOneWidget);
    expect(dotIsSelected(tester), isFalse);
  });

  testWidgets('passes the selected state down to the dot', (tester) async {
    await pump(tester, selected: true);
    expect(dotIsSelected(tester), isTrue);
  });

  testWidgets('tapping the label, not just the dot, reports', (tester) async {
    var taps = 0;
    await pump(tester, selected: false, onTap: () => taps++);

    await tester.tap(find.text('Every week'));
    await tester.pumpAndSettle();
    expect(taps, 1);
  });
}
