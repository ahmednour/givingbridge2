import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/design_system.dart';
import '../../core/utils/responsive_utils.dart';

/// Optimized image widget with responsive loading, caching, and compression
class OptimizedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;
  final bool enableMemoryCache;
  final bool enableDiskCache;
  final Duration? fadeInDuration;
  final String? heroTag;

  const OptimizedImage({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
    this.enableMemoryCache = true,
    this.enableDiskCache = true,
    this.fadeInDuration,
    this.heroTag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final optimizedUrl = _getOptimizedImageUrl(context);

    Widget imageWidget = CachedNetworkImage(
      imageUrl: optimizedUrl,
      width: width,
      height: height,
      fit: fit,
      memCacheWidth: _getMemoryCacheWidth(context),
      memCacheHeight: _getMemoryCacheHeight(context),
      placeholder: (context, url) => placeholder ?? _buildDefaultPlaceholder(),
      errorWidget: (context, url, error) =>
          errorWidget ?? _buildDefaultErrorWidget(),
      fadeInDuration: fadeInDuration ?? const Duration(milliseconds: 300),
      useOldImageOnUrlChange: true,
      cacheManager: enableDiskCache ? null : null, // Use default cache manager
    );

    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    if (heroTag != null) {
      imageWidget = Hero(
        tag: heroTag!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  /// Generate optimized image URL based on device capabilities
  String _getOptimizedImageUrl(BuildContext context) {
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final screenSize = ResponsiveUtils.getScreenSize(context);

    // Calculate optimal dimensions
    int? targetWidth;
    int? targetHeight;

    if (width != null) {
      targetWidth = (width! * devicePixelRatio).round();
    }
    if (height != null) {
      targetHeight = (height! * devicePixelRatio).round();
    }

    // Apply responsive sizing if dimensions not specified
    if (targetWidth == null && targetHeight == null) {
      switch (screenSize) {
        case ScreenSize.mobileSmall:
          targetWidth = 400;
          break;
        case ScreenSize.mobileMedium:
          targetWidth = 600;
          break;
        case ScreenSize.tablet:
          targetWidth = 800;
          break;
        case ScreenSize.desktop:
          targetWidth = 1200;
          break;
        case ScreenSize.desktopLarge:
          targetWidth = 1600;
          break;
      }
    }

    // For now, return original URL
    // In production, you would integrate with image optimization service
    // like Cloudinary, ImageKit, or AWS Lambda@Edge
    return _buildOptimizedUrl(imageUrl, targetWidth, targetHeight);
  }

  /// Build optimized URL with query parameters
  String _buildOptimizedUrl(String originalUrl, int? width, int? height) {
    // Example implementation for a generic image optimization service
    final uri = Uri.parse(originalUrl);
    final queryParams = Map<String, String>.from(uri.queryParameters);

    if (width != null) {
      queryParams['w'] = width.toString();
    }
    if (height != null) {
      queryParams['h'] = height.toString();
    }

    // Add quality and format optimization
    queryParams['q'] = '85'; // 85% quality for good balance
    queryParams['f'] = 'webp'; // Use WebP format when supported
    queryParams['auto'] = 'compress,format'; // Auto optimization

    return uri.replace(queryParameters: queryParams).toString();
  }

  /// Get memory cache width based on actual display size
  int? _getMemoryCacheWidth(BuildContext context) {
    if (width == null) return null;
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    return (width! * devicePixelRatio).round();
  }

  /// Get memory cache height based on actual display size
  int? _getMemoryCacheHeight(BuildContext context) {
    if (height == null) return null;
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    return (height! * devicePixelRatio).round();
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: DesignSystem.neutral100,
        borderRadius: borderRadius,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  DesignSystem.primaryBlue.withValues(alpha: 0.6),
                ),
              ),
            ),
            const SizedBox(height: DesignSystem.spaceS),
            Text(
              'Loading...',
              style: TextStyle(
                fontSize: 12,
                color: DesignSystem.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultErrorWidget() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: DesignSystem.neutral100,
        borderRadius: borderRadius,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: 32,
              color: DesignSystem.textSecondary,
            ),
            const SizedBox(height: DesignSystem.spaceS),
            Text(
              'Image not available',
              style: TextStyle(
                fontSize: 12,
                color: DesignSystem.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Responsive image widget that adapts to screen size
class ResponsiveImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;
  final String? heroTag;

  const ResponsiveImage({
    Key? key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
    this.heroTag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return OptimizedImage(
          imageUrl: imageUrl,
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          fit: fit,
          placeholder: placeholder,
          errorWidget: errorWidget,
          borderRadius: borderRadius,
          heroTag: heroTag,
        );
      },
    );
  }
}

/// Avatar image with optimized loading
class OptimizedAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double size;
  final Color? backgroundColor;
  final Color? textColor;

  const OptimizedAvatar({
    Key? key,
    this.imageUrl,
    this.name,
    this.size = 40,
    this.backgroundColor,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return OptimizedImage(
        imageUrl: imageUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        borderRadius: BorderRadius.circular(size / 2),
        placeholder: _buildFallbackAvatar(context),
        errorWidget: _buildFallbackAvatar(context),
      );
    }

    return _buildFallbackAvatar(context);
  }

  Widget _buildFallbackAvatar(BuildContext context) {
    final initials = _getInitials(name);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? DesignSystem.primaryBlue,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: DesignSystem.labelLarge(context).copyWith(
            color: textColor ?? Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: size * 0.4,
          ),
        ),
      ),
    );
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return '?';

    final words = name.trim().split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else if (words.isNotEmpty) {
      return words[0][0].toUpperCase();
    }

    return '?';
  }
}

/// Image gallery with lazy loading
class OptimizedImageGallery extends StatelessWidget {
  final List<String> imageUrls;
  final double itemHeight;
  final double spacing;
  final int crossAxisCount;

  const OptimizedImageGallery({
    Key? key,
    required this.imageUrls,
    this.itemHeight = 200,
    this.spacing = DesignSystem.spaceM,
    this.crossAxisCount = 2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveUtils.getCrossAxisCount(context),
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: 1.0,
      ),
      itemCount: imageUrls.length,
      itemBuilder: (context, index) {
        return OptimizedImage(
          imageUrl: imageUrls[index],
          fit: BoxFit.cover,
          borderRadius: BorderRadius.circular(DesignSystem.radiusM),
          heroTag: 'gallery_image_$index',
        );
      },
    );
  }
}

/// Lazy loading image list
class LazyImageList extends StatelessWidget {
  final List<String> imageUrls;
  final double itemHeight;
  final EdgeInsets? padding;

  const LazyImageList({
    Key? key,
    required this.imageUrls,
    this.itemHeight = 200,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: padding,
      itemCount: imageUrls.length,
      itemBuilder: (context, index) {
        return Container(
          height: itemHeight,
          margin: const EdgeInsets.only(bottom: DesignSystem.spaceM),
          child: OptimizedImage(
            imageUrl: imageUrls[index],
            fit: BoxFit.cover,
            borderRadius: BorderRadius.circular(DesignSystem.radiusM),
          ),
        );
      },
    );
  }
}
