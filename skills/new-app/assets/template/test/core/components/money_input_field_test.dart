import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kit_template_app/core/components/money_input_field.dart';

import '../../helpers/helpers.dart';

void main() {
  late TextEditingController controller;

  setUp(() {
    controller = TextEditingController();
    addTearDown(controller.dispose);
  });

  Future<void> pump(
    WidgetTester tester, {
    int maxDecimals = 2,
    bool enabled = true,
    String? labelText,
    void Function(String)? onChanged,
  }) => tester.pumpApp(
    Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: MoneyInputField(
          controller: controller,
          maxDecimals: maxDecimals,
          enabled: enabled,
          labelText: labelText,
          onChanged: onChanged,
        ),
      ),
    ),
  );

  testWidgets('groups thousands as the user types', (tester) async {
    await pump(tester);

    await tester.enterText(find.byType(TextField), '1234567');
    expect(controller.text, '1,234,567');
  });

  testWidgets('clamps the fraction to maxDecimals', (tester) async {
    await pump(tester);

    await tester.enterText(find.byType(TextField), '12.3456');
    expect(controller.text, '12.34');
  });

  testWidgets('maxDecimals zero drops the decimal part', (tester) async {
    await pump(tester, maxDecimals: 0);

    await tester.enterText(find.byType(TextField), '1234.56');
    expect(controller.text, '1,234');
  });

  testWidgets('strips anything that is not a digit or a point', (
    tester,
  ) async {
    await pump(tester);

    await tester.enterText(find.byType(TextField), r'12a$4');
    expect(controller.text, '124');
  });

  testWidgets('reports the formatted value through onChanged', (tester) async {
    String? seen;
    await pump(tester, onChanged: (value) => seen = value);

    await tester.enterText(find.byType(TextField), '9999');
    expect(seen, '9,999');
  });

  testWidgets('disabled fields reject input', (tester) async {
    await pump(tester, enabled: false);

    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
  });

  testWidgets('a label is rendered above the field', (tester) async {
    await pump(tester, labelText: 'Budget');

    expect(find.text('Budget'), findsOneWidget);
  });
}
