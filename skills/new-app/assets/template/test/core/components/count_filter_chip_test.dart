import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kit_template_app/config/theme/app_theme_colors.dart';
import 'package:kit_template_app/core/components/count_filter_chip.dart';
import 'package:kit_template_app/core/constants/app_gradient.dart';

import '../../helpers/helpers.dart';

void main() {
  Future<void> pump(
    WidgetTester tester, {
    required bool selected,
    int? count = 3,
    Gradient? countGradient,
    VoidCallback? onTap,
  }) => tester.pumpApp(
    Scaffold(
      body: Center(
        child: CountFilterChip(
          label: 'Active',
          count: count,
          selected: selected,
          countGradient: countGradient,
          onTap: onTap ?? () {},
        ),
      ),
    ),
  );

  BoxDecoration decorationOf(WidgetTester tester) =>
      tester
              .widget<Container>(
                find
                    .descendant(
                      of: find.byType(CountFilterChip),
                      matching: find.byType(Container),
                    )
                    .first,
              )
              .decoration!
          as BoxDecoration;

  Color labelColor(WidgetTester tester) =>
      tester.widget<Text>(find.text('Active')).style!.color!;

  testWidgets('shows the label and the count', (tester) async {
    await pump(tester, selected: false);

    expect(find.text('Active'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('drops the count badge when there is no count', (tester) async {
    await pump(tester, selected: false, count: null);

    expect(find.text('Active'), findsOneWidget);
    expect(find.text('3'), findsNothing);
  });

  testWidgets('unselected sits on the card colour', (tester) async {
    await pump(tester, selected: false);

    expect(decorationOf(tester).color, AppThemeColors.light.cards);
    expect(labelColor(tester), AppThemeColors.light.textHeading);
  });

  testWidgets('selected fills with the primary and inverts the label', (
    tester,
  ) async {
    await pump(tester, selected: true);

    expect(decorationOf(tester).color, AppThemeColors.light.primary);
    expect(labelColor(tester), isNot(AppThemeColors.light.textHeading));
  });

  testWidgets('a count gradient paints the count through a ShaderMask', (
    tester,
  ) async {
    await pump(tester, selected: false);
    expect(find.byType(ShaderMask), findsNothing);

    await pump(
      tester,
      selected: false,
      countGradient: AppGradient.primaryDiagonal,
    );
    expect(find.byType(ShaderMask), findsOneWidget);
  });

  testWidgets('tapping anywhere on the chip reports', (tester) async {
    var taps = 0;
    await pump(tester, selected: false, onTap: () => taps++);

    await tester.tap(find.byType(CountFilterChip));
    expect(taps, 1);
  });
}
