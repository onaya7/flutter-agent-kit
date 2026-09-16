import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:kit_template_app/config/theme/app_theme_colors.dart';
import 'package:kit_template_app/core/helpers/app_image_cache.dart';
import 'package:shimmer/shimmer.dart';

/// Cached network image; wraps the caching package so it can be swapped.
class CustomCachedImage extends StatelessWidget {
  const CustomCachedImage({
    required this.imageUrl,
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.shape = ImageShape.rectangle,
    this.borderRadius,
    this.radius = 30.0,
    this.backgroundColor,
    this.placeholder,
    this.errorWidget,
    this.errorIcon = Icons.image_not_supported_outlined,
    this.errorIconSize,
    this.showShimmer = true,
    this.shimmerBaseColor,
    this.shimmerHighlightColor,
    this.cacheManager,
  });

  factory CustomCachedImage.circular({
    required String imageUrl,
    Key? key,
    double radius = 30.0,
    Color? backgroundColor,
    Widget? placeholder,
    Widget? errorWidget,
    IconData errorIcon = Icons.person_outline_rounded,
    double? errorIconSize,
    bool showShimmer = true,
    BaseCacheManager? cacheManager,
  }) {
    return CustomCachedImage(
      key: key,
      imageUrl: imageUrl,
      shape: ImageShape.circle,
      radius: radius,
      backgroundColor: backgroundColor,
      placeholder: placeholder,
      errorWidget: errorWidget,
      errorIcon: errorIcon,
      errorIconSize: errorIconSize,
      showShimmer: showShimmer,
      cacheManager: cacheManager,
    );
  }

  factory CustomCachedImage.rectangle({
    required String imageUrl,
    Key? key,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
    Color? backgroundColor,
    Widget? placeholder,
    Widget? errorWidget,
    IconData errorIcon = Icons.image_not_supported_outlined,
    double? errorIconSize,
    bool showShimmer = true,
    BaseCacheManager? cacheManager,
  }) {
    return CustomCachedImage(
      key: key,
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      borderRadius: borderRadius,
      backgroundColor: backgroundColor,
      placeholder: placeholder,
      errorWidget: errorWidget,
      errorIcon: errorIcon,
      errorIconSize: errorIconSize,
      showShimmer: showShimmer,
      cacheManager: cacheManager,
    );
  }

  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final ImageShape shape;
  final BorderRadius? borderRadius;

  /// Half the drawn size when [shape] is [ImageShape.circle].
  final double radius;
  final Color? backgroundColor;
  final Widget? placeholder;
  final Widget? errorWidget;
  final IconData errorIcon;
  final double? errorIconSize;
  final bool showShimmer;
  final Color? shimmerBaseColor;
  final Color? shimmerHighlightColor;

  /// Injectable so a test can drive the load without touching the disk cache.
  final BaseCacheManager? cacheManager;

  @override
  Widget build(BuildContext context) {
    // A blank URL is the same "no image", so honour the caller's errorWidget.
    if (imageUrl.isEmpty) return errorWidget ?? _error(context);

    return CachedNetworkImage(
      imageUrl: imageUrl,
      cacheKey: AppImageCache.cacheKeyForUrl(imageUrl),
      cacheManager: cacheManager ?? AppImageCache.instance,
      width: shape == ImageShape.circle ? radius * 2 : width,
      height: shape == ImageShape.circle ? radius * 2 : height,
      fit: fit,
      imageBuilder: (context, provider) => _image(provider),
      placeholder: (context, url) => placeholder ?? _placeholder(context),
      errorWidget: (context, url, error) => errorWidget ?? _error(context),
    );
  }

  Widget _image(ImageProvider provider) {
    if (shape == ImageShape.circle) {
      return CircleAvatar(radius: radius, backgroundImage: provider);
    }
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        image: DecorationImage(image: provider, fit: fit),
      ),
    );
  }

  Widget _placeholder(BuildContext context) {
    final colors = AppThemeColors.of(context);
    final box = _box(context, null);
    if (!showShimmer) return box;
    return Shimmer.fromColors(
      baseColor: shimmerBaseColor ?? colors.strokeFill,
      highlightColor: shimmerHighlightColor ?? colors.stroke,
      child: box,
    );
  }

  Widget _error(BuildContext context) =>
      _box(context, AppThemeColors.of(context).iconLow);

  Widget _box(BuildContext context, Color? iconColor) {
    final colors = AppThemeColors.of(context);
    final fill = backgroundColor ?? colors.strokeFill;
    final glyph = iconColor == null
        ? null
        : Icon(
            errorIcon,
            color: iconColor,
            size: errorIconSize ?? (shape == ImageShape.circle ? radius : 40),
          );

    if (shape == ImageShape.circle) {
      return CircleAvatar(radius: radius, backgroundColor: fill, child: glyph);
    }
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: fill, borderRadius: borderRadius),
      child: glyph,
    );
  }
}

enum ImageShape { rectangle, circle }
