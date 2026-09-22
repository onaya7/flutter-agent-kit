import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kit_template_app/core/extensions/build_context_extension.dart';

void main() {
  Future<bool> isApple(WidgetTester tester, TargetPlatform platform) async {
    late bool result;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(platform: platform),
        home: Builder(
          builder: (context) {
            result = context.isApplePlatform;
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    return result;
  }

  // The point of the extension: a test can steer it. `Platform.isIOS` reports
  // the host machine, so one branch would never run on a given CI runner.
  testWidgets('is true on the Apple platforms', (tester) async {
    expect(await isApple(tester, TargetPlatform.iOS), isTrue);
    expect(await isApple(tester, TargetPlatform.macOS), isTrue);
  });

  testWidgets('is false elsewhere', (tester) async {
    expect(await isApple(tester, TargetPlatform.android), isFalse);
    expect(await isApple(tester, TargetPlatform.windows), isFalse);
  });
}
