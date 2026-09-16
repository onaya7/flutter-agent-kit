import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kit_template_app/core/components/custom_dashedborder.dart';
import 'package:kit_template_app/core/constants/app_color.dart';

import '../../helpers/helpers.dart';

void main() {
  testWidgets('paints a dashed outline around its child', (tester) async {
    await tester.pumpApp(
      Center(
        child: CustomPaint(
          painter: CustomDashedBorderPainter(color: AppColor.primary),
          child: const SizedBox(width: 140, height: 80),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(CustomPaint), findsWidgets);
  });

  testWidgets('survives a zero-sized box', (tester) async {
    await tester.pumpApp(
      Center(
        child: CustomPaint(
          painter: CustomDashedBorderPainter(color: AppColor.primary),
          child: const SizedBox.shrink(),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  group('shouldRepaint', () {
    final base = CustomDashedBorderPainter(color: AppColor.primary);

    test('is false for identical stroke settings', () {
      expect(
        base.shouldRepaint(CustomDashedBorderPainter(color: AppColor.primary)),
        isFalse,
      );
    });

    test('is true when the colour changes', () {
      expect(
        base.shouldRepaint(CustomDashedBorderPainter(color: AppColor.error)),
        isTrue,
      );
    });

    test('is true when the dash geometry changes', () {
      expect(
        base.shouldRepaint(
          CustomDashedBorderPainter(color: AppColor.primary, dashSpace: 9),
        ),
        isTrue,
      );
      expect(
        base.shouldRepaint(
          CustomDashedBorderPainter(color: AppColor.primary, radius: 2),
        ),
        isTrue,
      );
    });
  });
}
