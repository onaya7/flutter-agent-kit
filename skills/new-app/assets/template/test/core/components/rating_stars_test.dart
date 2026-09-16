import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kit_template_app/core/components/rating_stars.dart';
import 'package:kit_template_app/core/constants/app_color.dart';

import '../../helpers/helpers.dart';

void main() {
  Future<void> pump(
    WidgetTester tester, {
    required int rating,
    ValueChanged<int>? onChanged,
  }) => tester.pumpApp(
    Scaffold(
      body: Center(
        child: RatingStars(
          rating: rating,
          size: 24,
          onChanged: onChanged ?? (_) {},
        ),
      ),
    ),
  );

  testWidgets('an empty rating draws five outlines', (tester) async {
    await pump(tester, rating: 0);

    expect(find.byIcon(Icons.star_rounded), findsNothing);
    expect(find.byIcon(Icons.star_outline_rounded), findsNWidgets(5));
  });

  testWidgets('a partial rating fills only that many stars', (tester) async {
    await pump(tester, rating: 3);

    expect(find.byIcon(Icons.star_rounded), findsNWidgets(3));
    expect(find.byIcon(Icons.star_outline_rounded), findsNWidgets(2));
  });

  testWidgets('a full rating fills every star', (tester) async {
    await pump(tester, rating: 5);

    expect(find.byIcon(Icons.star_rounded), findsNWidgets(5));
    expect(find.byIcon(Icons.star_outline_rounded), findsNothing);
  });

  testWidgets('tapping a star reports its one-based position', (tester) async {
    int? picked;
    await pump(tester, rating: 3, onChanged: (value) => picked = value);

    await tester.tap(find.byIcon(Icons.star_outline_rounded).first);
    expect(picked, 4);

    await tester.tap(find.byIcon(Icons.star_rounded).first);
    expect(picked, 1);
  });

  testWidgets('stars take the warning colour by default', (tester) async {
    await pump(tester, rating: 1);

    expect(
      tester.widget<Icon>(find.byIcon(Icons.star_rounded)).color,
      AppColor.warning,
    );
  });
}
