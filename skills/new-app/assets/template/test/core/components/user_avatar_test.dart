import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kit_template_app/config/theme/app_theme_colors.dart';
import 'package:kit_template_app/core/components/user_avatar.dart';

import '../../helpers/helpers.dart';

void main() {
  Future<void> pump(WidgetTester tester, String name, {double radius = 20}) =>
      tester.pumpApp(
        Scaffold(
          body: Center(
            child: UserAvatar(name: name, radius: radius),
          ),
        ),
      );

  testWidgets('a full name becomes two initials', (tester) async {
    await pump(tester, 'Ada Lovelace');
    expect(find.text('AL'), findsOneWidget);
  });

  testWidgets('a single name becomes one initial', (tester) async {
    await pump(tester, 'Ada');
    expect(find.text('A'), findsOneWidget);
  });

  testWidgets('a middle name is ignored in favour of the last', (tester) async {
    await pump(tester, 'ada  byron lovelace');
    expect(find.text('AL'), findsOneWidget);
  });

  testWidgets('an empty name falls back to a person icon', (tester) async {
    await pump(tester, '   ');

    expect(find.byIcon(Icons.person_outline_rounded), findsOneWidget);
    expect(find.byType(Text), findsNothing);
  });

  testWidgets('the fallback sits on the theme primary', (tester) async {
    await pump(tester, 'Ada Lovelace');

    expect(
      tester.widget<CircleAvatar>(find.byType(CircleAvatar)).backgroundColor,
      AppThemeColors.light.primary,
    );
  });

  testWidgets('the radius drives the drawn size', (tester) async {
    await pump(tester, 'Ada Lovelace', radius: 32);
    expect(tester.getSize(find.byType(CircleAvatar)), const Size(64, 64));
  });
}
