import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kit_template_app/core/components/custom_cachedimage.dart';
import 'package:shimmer/shimmer.dart';

import '../../helpers/helpers.dart';

/// Drives the load from the test instead of the real on-disk cache.
class _StubCacheManager implements BaseCacheManager {
  _StubCacheManager(this.stream);

  final Stream<FileResponse> stream;

  @override
  Stream<FileResponse> getFileStream(
    String url, {
    String? key,
    Map<String, String>? headers,
    bool withProgress = false,
  }) => stream;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

void main() {
  const url = 'https://example.com/a.png?token=abc#top';

  Future<void> pump(WidgetTester tester, Widget image) =>
      tester.pumpApp(Scaffold(body: Center(child: image)));

  /// Tears the tree down so the placeholder's looping shimmer is disposed.
  Future<void> dispose(WidgetTester tester) =>
      tester.pumpWidget(const SizedBox.shrink());

  group('with no URL to load', () {
    testWidgets('an empty URL renders the error state, not a network image', (
      tester,
    ) async {
      await pump(tester, const CustomCachedImage(imageUrl: ''));

      expect(find.byType(CachedNetworkImage), findsNothing);
      expect(find.byIcon(Icons.image_not_supported_outlined), findsOneWidget);
    });

    testWidgets('an empty URL honours the caller error widget', (tester) async {
      await pump(
        tester,
        const CustomCachedImage(imageUrl: '', errorWidget: Text('no picture')),
      );

      expect(find.text('no picture'), findsOneWidget);
      expect(find.byIcon(Icons.image_not_supported_outlined), findsNothing);
    });

    testWidgets('the circular factory sizes itself from the radius', (
      tester,
    ) async {
      await pump(tester, CustomCachedImage.circular(imageUrl: '', radius: 24));

      expect(tester.getSize(find.byType(CircleAvatar)), const Size(48, 48));
    });
  });

  group('while loading', () {
    late StreamController<FileResponse> controller;

    setUp(() {
      // Broadcast so close() completes even though the image provider, torn down
      // with the tree, never drains it.
      controller = StreamController<FileResponse>.broadcast();
    });

    testWidgets('a pending load shows a shimmering placeholder', (
      tester,
    ) async {
      await pump(
        tester,
        CustomCachedImage(
          imageUrl: url,
          width: 100,
          height: 100,
          cacheManager: _StubCacheManager(controller.stream),
        ),
      );
      await tester.pump();

      expect(find.byType(Shimmer), findsOneWidget);
      await dispose(tester);
      await controller.close();
    });

    testWidgets('showShimmer false keeps a plain placeholder box', (
      tester,
    ) async {
      await pump(
        tester,
        CustomCachedImage(
          imageUrl: url,
          width: 100,
          height: 100,
          showShimmer: false,
          cacheManager: _StubCacheManager(controller.stream),
        ),
      );
      await tester.pump();

      expect(find.byType(Shimmer), findsNothing);
      expect(find.byType(CachedNetworkImage), findsOneWidget);
      await dispose(tester);
      await controller.close();
    });

    testWidgets('the cache key drops the query and fragment', (tester) async {
      await pump(
        tester,
        CustomCachedImage(
          imageUrl: url,
          showShimmer: false,
          cacheManager: _StubCacheManager(controller.stream),
        ),
      );
      await tester.pump();

      expect(
        tester
            .widget<CachedNetworkImage>(find.byType(CachedNetworkImage))
            .cacheKey,
        'https://example.com/a.png',
      );
      await dispose(tester);
      await controller.close();
    });
  });
}
