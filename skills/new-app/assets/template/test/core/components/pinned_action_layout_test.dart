import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kit_template_app/core/components/pinned_action_layout.dart';

import '../../helpers/helpers.dart';

void main() {
  const action = SizedBox(key: Key('action'), height: 52, width: 200);

  Future<void> pumpHost(
    WidgetTester tester, {
    required double viewportHeight,
    double keyboardInset = 0,
    bool centered = true,
    int blocks = 4,
  }) async {
    tester.view.physicalSize = Size(400, viewportHeight);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpApp(
      MediaQuery(
        data: MediaQueryData(
          size: Size(400, viewportHeight),
          viewInsets: EdgeInsets.only(bottom: keyboardInset),
        ),
        child: Scaffold(
          body: PinnedActionLayout(
            centered: centered,
            action: action,
            children: [
              for (var i = 0; i < blocks; i++)
                SizedBox(height: 120, child: Text('block $i')),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  // With the keyboard up the body used to overflow through the pinned action.
  testWidgets('does not overflow when a keyboard shrinks the viewport', (
    tester,
  ) async {
    await pumpHost(tester, viewportHeight: 700, keyboardInset: 340);

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('action')), findsOneWidget);
  });

  testWidgets('body scrolls instead of clipping when content overflows', (
    tester,
  ) async {
    await pumpHost(tester, viewportHeight: 600, blocks: 8);
    expect(tester.takeException(), isNull);

    final scrollable = find.byType(Scrollable);
    expect(scrollable, findsOneWidget);

    await tester.drag(scrollable, const Offset(0, -200));
    await tester.pumpAndSettle();
    expect(find.text('block 7'), findsOneWidget);
  });

  testWidgets('action stays pinned to the bottom when content is short', (
    tester,
  ) async {
    await pumpHost(tester, viewportHeight: 900, blocks: 1);

    final actionRect = tester.getRect(find.byKey(const Key('action')));
    expect(actionRect.bottom, closeTo(900 - 8, 0.5));
  });

  testWidgets('short content is centred, and top-aligned when not centered', (
    tester,
  ) async {
    await pumpHost(tester, viewportHeight: 900, blocks: 1);
    final centeredTop = tester.getRect(find.text('block 0')).top;

    await pumpHost(tester, viewportHeight: 900, blocks: 1, centered: false);
    final alignedTop = tester.getRect(find.text('block 0')).top;

    expect(centeredTop, greaterThan(alignedTop));
    expect(alignedTop, closeTo(0, 0.5));
  });
}
