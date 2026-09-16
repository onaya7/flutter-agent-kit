import 'package:flutter_test/flutter_test.dart';
import 'package:kit_template_app/core/helpers/app_image_cache.dart';

void main() {
  group('cacheKeyForUrl', () {
    test('drops the query so a signed URL keeps one key', () {
      expect(
        AppImageCache.cacheKeyForUrl(
          'https://cdn.example.com/a.png?sig=1&exp=2',
        ),
        'https://cdn.example.com/a.png',
      );
    });

    test('drops the fragment too', () {
      expect(
        AppImageCache.cacheKeyForUrl('https://cdn.example.com/a.png#frag'),
        'https://cdn.example.com/a.png',
      );
    });

    test('leaves a plain URL untouched', () {
      expect(
        AppImageCache.cacheKeyForUrl('https://cdn.example.com/a.png'),
        'https://cdn.example.com/a.png',
      );
    });

    test('two signings of one asset share a key', () {
      expect(
        AppImageCache.cacheKeyForUrl('https://cdn.example.com/a.png?sig=1'),
        AppImageCache.cacheKeyForUrl('https://cdn.example.com/a.png?sig=2'),
      );
    });

    test('a query before a fragment is cut at the query', () {
      expect(
        AppImageCache.cacheKeyForUrl('https://cdn.example.com/a.png?s=1#top'),
        'https://cdn.example.com/a.png',
      );
    });
  });
}
