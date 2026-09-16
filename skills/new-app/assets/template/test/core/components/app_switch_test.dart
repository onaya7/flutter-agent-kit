import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kit_template_app/config/theme/app_theme_colors.dart';
import 'package:kit_template_app/core/components/app_switch.dart';

import '../../helpers/helpers.dart';

void main() {
  Future<void> pump(
    WidgetTester tester, {
    required bool value,
    ValueChanged<bool>? onChanged,
    Color? activeColor,
  }) => tester.pumpApp(
    Scaffold(
      body: Center(
        child: AppSwitch(
          value: value,
          activeColor: activeColor,
          onChanged: onChanged ?? (_) {},
        ),
      ),
    ),
  );

  Switch rendered(WidgetTester tester) =>
      tester.widget<Switch>(find.byType(Switch));

  testWidgets('renders both the on and the off state', (tester) async {
    await pump(tester, value: true);
    expect(rendered(tester).value, isTrue);

    await pump(tester, value: false);
    expect(rendered(tester).value, isFalse);
  });

  testWidgets('tapping reports the flipped value', (tester) async {
    bool? seen;
    await pump(tester, value: false, onChanged: (v) => seen = v);

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(seen, isTrue);
  });

  testWidgets('the on track defaults to the theme primary', (tester) async {
    await pump(tester, value: true);
    expect(rendered(tester).activeTrackColor, AppThemeColors.light.primary);
  });

  testWidgets('an explicit activeColor wins over the theme', (tester) async {
    await pump(tester, value: true, activeColor: const Color(0xFF00FF00));
    expect(rendered(tester).activeTrackColor, const Color(0xFF00FF00));
  });
}
