import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kit_template_app/core/components/date_picker_field.dart';

import '../../helpers/helpers.dart';

void main() {
  Future<void> pump(
    WidgetTester tester, {
    DateTime? date,
    VoidCallback? onTap,
  }) => tester.pumpApp(
    Scaffold(
      body: Center(
        child: DatePickerField(date: date, onTap: onTap ?? () {}),
      ),
    ),
  );

  testWidgets('shows the placeholder when nothing is picked', (tester) async {
    await pump(tester);
    expect(find.text('DD/MM/YY'), findsOneWidget);
  });

  testWidgets('renders a picked date as DD/MM/YY', (tester) async {
    await pump(tester, date: DateTime(2024, 3, 7));

    expect(find.text('07/03/24'), findsOneWidget);
    expect(find.text('DD/MM/YY'), findsNothing);
  });

  testWidgets('pads a single-digit year of the century', (tester) async {
    await pump(tester, date: DateTime(2007, 12, 25));
    expect(find.text('25/12/07'), findsOneWidget);
  });

  testWidgets('tapping opens the picker', (tester) async {
    var taps = 0;
    await pump(tester, onTap: () => taps++);

    await tester.tap(find.byType(DatePickerField));
    await tester.pumpAndSettle();
    expect(taps, 1);
  });
}
