import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// The disk cache behind `CustomCachedImage`, and its cache-key rule.
abstract class AppImageCache {
  static const _cacheKey = 'app_image_cache';
  static const _maxCacheFiles = 200;
  static const _stalePeriod = Duration(days: 14);

  static CacheManager? _instance;

  static CacheManager get instance {
    return _instance ??= CacheManager(
      Config(
        _cacheKey,
        maxNrOfCacheObjects: _maxCacheFiles,
        stalePeriod: _stalePeriod,
        repo: JsonCacheInfoRepository(databaseName: _cacheKey),
      ),
    );
  }

  /// Signed URLs carry time-based tokens, so the query can't be part of the key.
  static String cacheKeyForUrl(String url) {
    final cut = url.indexOf(RegExp('[?#]'));
    return cut == -1 ? url : url.substring(0, cut);
  }
}
