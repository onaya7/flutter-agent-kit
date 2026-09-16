import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kit_template_app/core/components/filter_pill.dart';

import '../../helpers/helpers.dart';

void main() {
  Future<void> pump(WidgetTester tester, FilterPill pill) =>
      tester.pumpApp(Scaffold(body: Center(child: pill)));

  testWidgets('icon-only is a circle of the given size', (tester) async {
    await pump(tester, const FilterPill(icon: Icons.tune, size: 44));

    expect(tester.getSize(find.byType(FilterPill)), const Size(44, 44));
    expect(find.byIcon(Icons.tune), findsOneWidget);
  });

  testWidgets('a label widens the pill and is rendered', (tester) async {
    await pump(tester, const FilterPill(icon: Icons.tune, label: 'Filters'));

    expect(find.text('Filters'), findsOneWidget);
    expect(tester.getSize(find.byType(FilterPill)).width, greaterThan(40));
  });

  testWidgets('tapping reports when enabled', (tester) async {
    var taps = 0;
    await pump(tester, FilterPill(icon: Icons.tune, onTap: () => taps++));

    await tester.tap(find.byType(FilterPill));
    await tester.pumpAndSettle();
    expect(taps, 1);
  });

  testWidgets('without onTap it is inert', (tester) async {
    await pump(tester, const FilterPill(icon: Icons.tune));

    expect(
      tester.widget<GestureDetector>(find.byType(GestureDetector).last).onTap,
      isNull,
    );
    await tester.tap(find.byType(FilterPill));
    expect(tester.takeException(), isNull);
  });
}
