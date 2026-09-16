import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kit_template_app/core/components/custom_ripple.dart';

import '../../helpers/helpers.dart';

void main() {
  Future<void> pump(WidgetTester tester, CustomRipple ripple) =>
      tester.pumpApp(Scaffold(body: Center(child: ripple)));

  testWidgets('forwards a tap', (tester) async {
    var taps = 0;
    await pump(
      tester,
      CustomRipple(
        onTap: () => taps++,
        child: const SizedBox(width: 120, height: 48),
      ),
    );

    await tester.tap(find.byType(CustomRipple));
    expect(taps, 1);
  });

  testWidgets('forwards a long press', (tester) async {
    var pressed = 0;
    await pump(
      tester,
      CustomRipple(
        onLongPress: () => pressed++,
        child: const SizedBox(width: 120, height: 48),
      ),
    );

    await tester.longPress(find.byType(CustomRipple));
    expect(pressed, 1);
  });

  testWidgets('forwards a double tap', (tester) async {
    var doubles = 0;
    await pump(
      tester,
      CustomRipple(
        onDoubleTap: () => doubles++,
        child: const SizedBox(width: 120, height: 48),
      ),
    );

    await tester.tap(find.byType(CustomRipple));
    await tester.pump(kDoubleTapMinTime);
    await tester.tap(find.byType(CustomRipple));
    await tester.pumpAndSettle();
    expect(doubles, 1);
  });

  testWidgets('without callbacks it is inert but still builds', (tester) async {
    await pump(
      tester,
      const CustomRipple(child: SizedBox(width: 120, height: 48)),
    );

    await tester.tap(find.byType(CustomRipple));
    expect(tester.takeException(), isNull);
  });

  testWidgets('a border radius clips the ink, a bare ripple does not', (
    tester,
  ) async {
    await pump(
      tester,
      CustomRipple(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: const SizedBox(width: 120, height: 48),
      ),
    );
    expect(
      tester.widget<Material>(find.byType(Material).last).clipBehavior,
      Clip.antiAlias,
    );

    await pump(
      tester,
      CustomRipple(onTap: () {}, child: const SizedBox(width: 120, height: 48)),
    );
    expect(
      tester.widget<Material>(find.byType(Material).last).clipBehavior,
      Clip.none,
    );
  });
}
