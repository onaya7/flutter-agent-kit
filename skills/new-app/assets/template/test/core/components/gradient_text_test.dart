import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kit_template_app/core/components/gradient_text.dart';
import 'package:kit_template_app/core/constants/app_color.dart';

import '../../helpers/helpers.dart';

void main() {
  Future<void> pump(WidgetTester tester, GradientText text) =>
      tester.pumpApp(Scaffold(body: Center(child: text)));

  testWidgets('paints its text through a ShaderMask', (tester) async {
    await pump(
      tester,
      const GradientText(
        'Learn more',
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );

    expect(find.text('Learn more'), findsOneWidget);
    expect(find.byType(ShaderMask), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('underline is off by default and on when asked', (tester) async {
    await pump(
      tester,
      const GradientText('Link', fontSize: 14, fontWeight: FontWeight.w400),
    );
    expect(tester.widget<Text>(find.text('Link')).style!.decoration, isNull);

    await pump(
      tester,
      const GradientText(
        'Link',
        fontSize: 14,
        fontWeight: FontWeight.w400,
        underline: true,
      ),
    );
    expect(
      tester.widget<Text>(find.text('Link')).style!.decoration,
      TextDecoration.underline,
    );
  });

  testWidgets('accepts a caller gradient', (tester) async {
    await pump(
      tester,
      const GradientText(
        'Link',
        fontSize: 14,
        fontWeight: FontWeight.w400,
        gradient: LinearGradient(colors: [AppColor.info, AppColor.success]),
      ),
    );

    expect(find.byType(ShaderMask), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
