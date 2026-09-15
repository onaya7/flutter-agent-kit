import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kit_template_app/core/components/custom_inputfield.dart';

import '../../helpers/helpers.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget field) async {
    await tester.pumpApp(
      Scaffold(
        body: Padding(padding: const EdgeInsets.all(16), child: field),
      ),
    );
    await tester.pumpAndSettle();
  }

  TextField renderedField(WidgetTester tester) =>
      tester.widget<TextField>(find.byType(TextField));

  group('CustomInputField renders every variant', () {
    for (final variant in InputFieldVariant.values) {
      testWidgets('$variant builds without assertions', (tester) async {
        await pump(
          tester,
          CustomInputField(variant: variant, hintText: 'hint'),
        );
        expect(find.byType(TextField), findsOneWidget);
      });
    }
  });

  group('multiline fields keep a usable newline key', () {
    // Pairing newline with the text keyboard trips a TextField assertion.
    testWidgets('a multiline field gets newline + the multiline keyboard', (
      tester,
    ) async {
      await pump(
        tester,
        const CustomInputField(
          variant: InputFieldVariant.textArea,
          maxlines: 4,
          minLines: 4,
        ),
      );

      final field = renderedField(tester);
      expect(field.textInputAction, TextInputAction.newline);
      expect(field.keyboardType, TextInputType.multiline);
    });

    testWidgets('an explicit multiline keyboard is left alone', (tester) async {
      await pump(
        tester,
        const CustomInputField(
          maxlines: 6,
          keyboardType: TextInputType.multiline,
        ),
      );
      expect(renderedField(tester).keyboardType, TextInputType.multiline);
    });

    testWidgets('a caller-supplied action wins over the newline default', (
      tester,
    ) async {
      await pump(
        tester,
        const CustomInputField(maxlines: 4, action: TextInputAction.done),
      );

      final field = renderedField(tester);
      expect(field.textInputAction, TextInputAction.done);
      expect(field.keyboardType, TextInputType.text);
    });

    testWidgets('a non-text keyboard survives the newline default', (
      tester,
    ) async {
      await pump(
        tester,
        const CustomInputField(maxlines: 4, keyboardType: TextInputType.number),
      );
      expect(renderedField(tester).keyboardType, TextInputType.number);
    });
  });

  group('single-line fields', () {
    testWidgets('default to the done action', (tester) async {
      await pump(tester, const CustomInputField());

      final field = renderedField(tester);
      expect(field.textInputAction, TextInputAction.done);
      expect(field.keyboardType, TextInputType.text);
    });

    testWidgets('use next when chained to another field', (tester) async {
      final next = FocusNode();
      addTearDown(next.dispose);

      await pump(tester, CustomInputField(nextFocus: next));
      expect(renderedField(tester).textInputAction, TextInputAction.next);
    });

    testWidgets('submitting moves focus to nextFocus', (tester) async {
      final current = FocusNode();
      final next = FocusNode();
      addTearDown(current.dispose);
      addTearDown(next.dispose);

      await pump(
        tester,
        Column(
          children: [
            CustomInputField(currentFocus: current, nextFocus: next),
            CustomInputField(currentFocus: next),
          ],
        ),
      );

      await tester.tap(find.byType(TextField).first);
      await tester.pumpAndSettle();
      expect(current.hasFocus, isTrue);

      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pumpAndSettle();
      expect(next.hasFocus, isTrue);
    });
  });

  group('keyboard dismissal', () {
    testWidgets('tapping outside unfocuses a field with no focus node', (
      tester,
    ) async {
      await pump(
        tester,
        const Column(
          children: [
            CustomInputField(hintText: 'field'),
            SizedBox(height: 200, width: double.infinity),
          ],
        ),
      );

      bool editableHasFocus() => tester
          .state<EditableTextState>(find.byType(EditableText))
          .widget
          .focusNode
          .hasFocus;

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      expect(editableHasFocus(), isTrue);

      await tester.tapAt(tester.getCenter(find.byType(SizedBox).last));
      await tester.pumpAndSettle();
      expect(editableHasFocus(), isFalse);
    });

    testWidgets('tapping outside unfocuses a field that has one', (
      tester,
    ) async {
      final focus = FocusNode();
      addTearDown(focus.dispose);

      await pump(
        tester,
        Column(
          children: [
            CustomInputField(currentFocus: focus),
            const SizedBox(height: 200, width: double.infinity),
          ],
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      expect(focus.hasFocus, isTrue);

      await tester.tapAt(tester.getCenter(find.byType(SizedBox).last));
      await tester.pumpAndSettle();
      expect(focus.hasFocus, isFalse);
    });
  });

  group('password fields', () {
    testWidgets('obscure text and expose the toggle', (tester) async {
      var toggled = false;
      await pump(
        tester,
        CustomInputField(
          isPasswordField: true,
          obscureText: true,
          onSuffixIconTap: () => toggled = true,
        ),
      );

      expect(renderedField(tester).obscureText, isTrue);
      await tester.tap(find.byType(IconButton));
      expect(toggled, isTrue);
    });
  });

  testWidgets('labelText wraps the field in a labelled column', (tester) async {
    await pump(tester, const CustomInputField(labelText: 'Email'));

    expect(find.text('Email'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('inputFormatters and onChanged are forwarded', (tester) async {
    String? seen;
    await pump(
      tester,
      CustomInputField(
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (value) => seen = value,
      ),
    );

    await tester.enterText(find.byType(TextField), 'a1b2');
    expect(seen, '12');
  });
}
