import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kit_template_app/core/helpers/keyboard_dismissal.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    scrollBehavior: KeyboardDismissal.scrollBehavior,
    builder: (context, built) => Actions(
      actions: KeyboardDismissal.tapOutsideActions,
      child: built ?? const SizedBox.shrink(),
    ),
    home: Scaffold(body: child),
  );

  // Mobile is the only platform where Flutter's defaults do nothing.
  testWidgets(
    'an outside tap unfocuses a field that sets no onTapOutside',
    (tester) async {
      final focus = FocusNode();
      addTearDown(focus.dispose);

      await tester.pumpWidget(
        wrap(
          Column(
            children: [
              TextField(focusNode: focus),
              const SizedBox(height: 300, width: double.infinity),
            ],
          ),
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      expect(focus.hasFocus, isTrue);

      await tester.tapAt(tester.getCenter(find.byType(SizedBox).last));
      await tester.pumpAndSettle();
      expect(
        focus.hasFocus,
        isFalse,
        reason: 'the root EditableTextTapOutsideIntent override did not run',
      );
    },
    variant: TargetPlatformVariant.mobile(),
  );

  testWidgets('a scroll view with no explicit behaviour dismisses on drag', (
    tester,
  ) async {
    final focus = FocusNode();
    addTearDown(focus.dispose);

    await tester.pumpWidget(
      wrap(
        ListView(
          children: [
            TextField(focusNode: focus),
            for (var i = 0; i < 30; i++)
              SizedBox(height: 60, child: Text('$i')),
          ],
        ),
      ),
    );

    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();
    expect(focus.hasFocus, isTrue);

    await tester.drag(find.byType(ListView), const Offset(0, -200));
    await tester.pumpAndSettle();
    expect(
      focus.hasFocus,
      isFalse,
      reason: 'the ListView did not inherit onDrag from scrollBehavior',
    );
  });

  // `manual` is not an opt-out: a drag begins with a pointer-down.
  testWidgets('an outside drag dismisses even when the scrollable opts out', (
    tester,
  ) async {
    final focus = FocusNode();
    addTearDown(focus.dispose);

    await tester.pumpWidget(
      wrap(
        ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
          children: [
            TextField(focusNode: focus),
            for (var i = 0; i < 30; i++)
              SizedBox(height: 60, child: Text('$i')),
          ],
        ),
      ),
    );

    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();
    expect(focus.hasFocus, isTrue);

    await tester.drag(find.byType(ListView), const Offset(0, -200));
    await tester.pumpAndSettle();
    expect(focus.hasFocus, isFalse);
  });
}
