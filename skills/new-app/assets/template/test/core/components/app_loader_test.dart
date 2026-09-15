import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kit_template_app/core/components/app_loader.dart';

import '../../helpers/helpers.dart';

Future<void> _pumpOverlay(WidgetTester tester) => tester.pumpApp(
  const AppLoaderOverlay(child: Scaffold(body: Text('behind'))),
);

/// The scrim's spinner; nothing else in this tree draws one.
Finder get _scrim => find.byType(CircularProgressIndicator);

/// `pumpAndSettle` never returns: the scrim's animations loop forever.
Future<void> _settle(WidgetTester tester) =>
    tester.pump(const Duration(milliseconds: 300));

void main() {
  setUp(AppLoader.reset);
  tearDown(AppLoader.reset);

  testWidgets('the overlay follows the reference count', (tester) async {
    await _pumpOverlay(tester);
    expect(_scrim, findsNothing);

    AppLoader.show();
    AppLoader.show();
    await _settle(tester);
    expect(_scrim, findsOneWidget);

    AppLoader.hide();
    await _settle(tester);
    expect(_scrim, findsOneWidget);

    AppLoader.hide();
    await _settle(tester);
    expect(_scrim, findsNothing);
  });

  testWidgets('a suspension hides the overlay without dropping the count', (
    tester,
  ) async {
    await _pumpOverlay(tester);
    AppLoader.show();
    await _settle(tester);
    expect(_scrim, findsOneWidget);

    final release = Completer<void>();
    final suspended = AppLoader.suspendedDuring(() => release.future);
    await _settle(tester);
    expect(_scrim, findsNothing);
    expect(AppLoader.isVisible, isFalse);

    release.complete();
    await suspended;
    await _settle(tester);
    expect(_scrim, findsOneWidget);

    AppLoader.hide();
    await _settle(tester);
    expect(_scrim, findsNothing);
  });

  testWidgets('a suspension that throws still restores the overlay', (
    tester,
  ) async {
    await _pumpOverlay(tester);
    AppLoader.show();
    await _settle(tester);

    await expectLater(
      AppLoader.suspendedDuring<void>(() async => throw StateError('nope')),
      throwsStateError,
    );
    await _settle(tester);
    expect(_scrim, findsOneWidget);
  });

  testWidgets('nothing is shown when a suspension outlives the count', (
    tester,
  ) async {
    await _pumpOverlay(tester);
    AppLoader.show();

    final release = Completer<void>();
    final suspended = AppLoader.suspendedDuring(() => release.future);
    AppLoader.hide();
    release.complete();
    await suspended;
    await _settle(tester);
    expect(_scrim, findsNothing);
  });
}
