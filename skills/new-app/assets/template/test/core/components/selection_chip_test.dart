import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kit_template_app/config/theme/app_theme_colors.dart';
import 'package:kit_template_app/core/components/selection_chip.dart';

import '../../helpers/helpers.dart';

void main() {
  group('SelectionChip', () {
    Future<void> pump(
      WidgetTester tester, {
      required bool selected,
      VoidCallback? onTap,
    }) => tester.pumpApp(
      Scaffold(
        body: Center(
          child: SelectionChip(
            label: 'Plumbing',
            selected: selected,
            onTap: onTap ?? () {},
          ),
        ),
      ),
    );

    Border borderOf(WidgetTester tester) =>
        (tester
                        .widget<AnimatedContainer>(
                          find.byType(AnimatedContainer),
                        )
                        .decoration!
                    as BoxDecoration)
                .border!
            as Border;

    TextStyle styleOf(WidgetTester tester) =>
        tester.widget<Text>(find.text('Plumbing')).style!;

    testWidgets('unselected is a thin neutral outline', (tester) async {
      await pump(tester, selected: false);

      expect(borderOf(tester).top.color, AppThemeColors.light.stroke);
      expect(borderOf(tester).top.width, 1);
      expect(styleOf(tester).color, AppThemeColors.light.textHeading);
      expect(styleOf(tester).fontWeight, FontWeight.w400);
    });

    testWidgets('selected thickens the outline and bolds the label', (
      tester,
    ) async {
      await pump(tester, selected: true);
      await tester.pumpAndSettle();

      expect(borderOf(tester).top.color, AppThemeColors.light.primary);
      expect(borderOf(tester).top.width, 1.5);
      expect(styleOf(tester).color, AppThemeColors.light.primary);
      expect(styleOf(tester).fontWeight, FontWeight.w600);
    });

    testWidgets('tapping reports', (tester) async {
      var taps = 0;
      await pump(tester, selected: false, onTap: () => taps++);

      await tester.tap(find.byType(SelectionChip));
      await tester.pumpAndSettle();
      expect(taps, 1);
    });
  });

  group('RemovableChip', () {
    testWidgets('shows the label with a remove affordance', (tester) async {
      await tester.pumpApp(
        Scaffold(
          body: Center(
            child: RemovableChip(label: 'Plumbing', onRemove: () {}),
          ),
        ),
      );

      expect(find.text('Plumbing'), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    });

    testWidgets('only the close icon removes', (tester) async {
      var removed = 0;
      await tester.pumpApp(
        Scaffold(
          body: Center(
            child: RemovableChip(label: 'Plumbing', onRemove: () => removed++),
          ),
        ),
      );

      await tester.tap(find.text('Plumbing'));
      await tester.pumpAndSettle();
      expect(removed, 0);

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();
      expect(removed, 1);
    });
  });
}
