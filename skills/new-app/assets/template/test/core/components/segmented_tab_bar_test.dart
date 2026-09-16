import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kit_template_app/config/theme/app_theme_colors.dart';
import 'package:kit_template_app/core/components/segmented_tab_bar.dart';

import '../../helpers/helpers.dart';

void main() {
  Future<void> pump(
    WidgetTester tester, {
    required int selectedIndex,
    ValueChanged<int>? onSelected,
  }) => tester.pumpApp(
    Scaffold(
      body: SegmentedTabBar(
        tabs: const ['Open', 'Closed', 'Draft'],
        selectedIndex: selectedIndex,
        onSelected: onSelected ?? (_) {},
      ),
    ),
  );

  Color colorOf(WidgetTester tester, String label) =>
      tester.widget<Text>(find.text(label)).style!.color!;

  testWidgets('renders every tab', (tester) async {
    await pump(tester, selectedIndex: 0);

    expect(find.text('Open'), findsOneWidget);
    expect(find.text('Closed'), findsOneWidget);
    expect(find.text('Draft'), findsOneWidget);
  });

  testWidgets('only the selected tab reads as a heading', (tester) async {
    await pump(tester, selectedIndex: 1);

    expect(colorOf(tester, 'Closed'), AppThemeColors.light.textHeading);
    expect(colorOf(tester, 'Open'), AppThemeColors.light.subtext);
    expect(colorOf(tester, 'Draft'), AppThemeColors.light.subtext);
  });

  testWidgets('the underline moves with the selection', (tester) async {
    await pump(tester, selectedIndex: 0);
    expect(colorOf(tester, 'Open'), AppThemeColors.light.textHeading);

    await pump(tester, selectedIndex: 2);
    expect(colorOf(tester, 'Open'), AppThemeColors.light.subtext);
    expect(colorOf(tester, 'Draft'), AppThemeColors.light.textHeading);
  });

  testWidgets('tapping a tab reports its index', (tester) async {
    int? picked;
    await pump(tester, selectedIndex: 0, onSelected: (i) => picked = i);

    await tester.tap(find.text('Draft'));
    await tester.pumpAndSettle();
    expect(picked, 2);
  });

  testWidgets('re-tapping the active tab still reports', (tester) async {
    int? picked;
    await pump(tester, selectedIndex: 1, onSelected: (i) => picked = i);

    await tester.tap(find.text('Closed'));
    await tester.pumpAndSettle();
    expect(picked, 1);
  });
}
