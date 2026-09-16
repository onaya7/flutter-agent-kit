import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kit_template_app/config/theme/app_theme_colors.dart';
import 'package:kit_template_app/core/components/search_bar_field.dart';

import '../../helpers/helpers.dart';

void main() {
  Future<void> pump(WidgetTester tester, {String? hint, VoidCallback? onTap}) =>
      tester.pumpApp(
        Scaffold(
          body: Center(
            child: hint == null
                ? SearchBarField(onTap: onTap ?? () {})
                : SearchBarField(hint: hint, onTap: onTap ?? () {}),
          ),
        ),
      );

  testWidgets('shows a neutral default hint', (tester) async {
    await pump(tester);
    expect(find.text('Search'), findsOneWidget);
  });

  testWidgets('accepts a caller hint', (tester) async {
    await pump(tester, hint: 'Search orders');

    expect(find.text('Search orders'), findsOneWidget);
    expect(find.text('Search'), findsNothing);
  });

  testWidgets('takes no input of its own', (tester) async {
    await pump(tester);
    expect(find.byType(EditableText), findsNothing);
  });

  testWidgets('tapping opens the search surface', (tester) async {
    var taps = 0;
    await pump(tester, onTap: () => taps++);

    await tester.tap(find.byType(SearchBarField));
    expect(taps, 1);
  });

  testWidgets('the hint follows the dark palette', (tester) async {
    await tester.pumpApp(
      Scaffold(
        body: Center(child: SearchBarField(onTap: () {})),
      ),
      themeMode: ThemeMode.dark,
    );

    expect(
      tester.widget<Text>(find.text('Search')).style!.color,
      AppThemeColors.dark.subtext,
    );
  });
}
