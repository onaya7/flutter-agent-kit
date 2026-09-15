import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kit_template_app/core/components/feedback_sheet.dart';

import '../../helpers/helpers.dart';

void main() {
  /// Routed through GoRouter: the sheet closes via `context.pop`.
  Future<Future<bool?>> openSheet(
    WidgetTester tester, {
    String? secondaryActionLabel,
    bool showClose = false,
  }) async {
    late Future<bool?> result;
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => result = showFeedbackSheet(
                  context,
                  kind: FeedbackKind.caution,
                  title: 'You are about to delete this item',
                  message: 'Are you sure you want to delete this item',
                  actionLabel: 'Yes, Delete',
                  secondaryActionLabel: secondaryActionLabel,
                  showClose: showClose,
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpApp(null, router: router);
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return result;
  }

  testWidgets('acknowledge-only callers keep a single button and no close', (
    tester,
  ) async {
    final result = await openSheet(tester);

    expect(find.text('Yes, Delete'), findsOneWidget);
    expect(find.text('Cancel'), findsNothing);
    expect(find.byIcon(Icons.close_rounded), findsNothing);

    await tester.tap(find.text('Yes, Delete'));
    await tester.pumpAndSettle();
    expect(await result, isTrue);
  });

  testWidgets('the confirm variant renders the title, body and both actions', (
    tester,
  ) async {
    await openSheet(tester, secondaryActionLabel: 'Cancel', showClose: true);

    expect(find.text('You are about to delete this item'), findsOneWidget);
    expect(
      find.text('Are you sure you want to delete this item'),
      findsOneWidget,
    );
    expect(find.text('Yes, Delete'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);
  });

  testWidgets('the secondary action resolves false, not null', (tester) async {
    final result = await openSheet(
      tester,
      secondaryActionLabel: 'Cancel',
      showClose: true,
    );

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(await result, isFalse);
  });

  testWidgets('the close icon resolves false', (tester) async {
    final result = await openSheet(
      tester,
      secondaryActionLabel: 'Cancel',
      showClose: true,
    );

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    expect(await result, isFalse);
  });
}
