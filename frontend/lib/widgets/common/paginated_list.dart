import 'package:flutter/material.dart';
import '../../core/constants/ui_constants.dart';
import '../../core/theme/app_theme_enhanced.dart';
import '../../widgets/app_components.dart';

/// Paginated list widget with lazy loading and performance optimizations
class PaginatedList<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final VoidCallback? onLoadMore;
  final bool hasMoreData;
  final bool isLoading;
  final String? emptyMessage;
  final Widget? emptyWidget;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final EdgeInsets? padding;
  final ScrollController? scrollController;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final int crossAxisCount;
  final double childAspectRatio;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final bool useGridView;

  const PaginatedList({
    Key? key,
    required this.items,
    required this.itemBuilder,
    this.onLoadMore,
    this.hasMoreData = false,
    this.isLoading = false,
    this.emptyMessage,
    this.emptyWidget,
    this.loadingWidget,
    this.errorWidget,
    this.errorMessage,
    this.onRetry,
    this.padding,
    this.scrollController,
    this.shrinkWrap = false,
    this.physics,
    this.crossAxisCount = 1,
    this.childAspectRatio = 1.0,
    this.crossAxisSpacing = UIConstants.spacingM,
    this.mainAxisSpacing = UIConstants.spacingM,
    this.useGridView = false,
  }) : super(key: key);

  @override
  State<PaginatedList<T>> createState() => _PaginatedListState<T>();
}

class _PaginatedListState<T> extends State<PaginatedList<T>> {
  late ScrollController _scrollController;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (widget.hasMoreData && !widget.isLoading && !_isLoadingMore) {
        setState(() {
          _isLoadingMore = true;
        });
        widget.onLoadMore?.call();
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _isLoadingMore = false;
            });
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.errorMessage != null) {
      return _buildErrorState();
    }

    if (widget.items.isEmpty && !widget.isLoading) {
      return _buildEmptyState();
    }

    return _buildList();
  }

  Widget _buildList() {
    if (widget.useGridView) {
      return _buildGridView();
    } else {
      return _buildListView();
    }
  }

  Widget _buildListView() {
    return ListView.builder(
      controller: _scrollController,
      padding: widget.padding,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
      itemCount: widget.items.length + _getFooterItemCount(),
      itemBuilder: (context, index) {
        if (index < widget.items.length) {
          return widget.itemBuilder(context, widget.items[index], index);
        } else {
          return _buildFooterItem(index - widget.items.length);
        }
      },
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      controller: _scrollController,
      padding: widget.padding,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.crossAxisCount,
        childAspectRatio: widget.childAspectRatio,
        crossAxisSpacing: widget.crossAxisSpacing,
        mainAxisSpacing: widget.mainAxisSpacing,
      ),
      itemCount: widget.items.length + _getFooterItemCount(),
      itemBuilder: (context, index) {
        if (index < widget.items.length) {
          return widget.itemBuilder(context, widget.items[index], index);
        } else {
          return _buildFooterItem(index - widget.items.length);
        }
      },
    );
  }

  Widget _buildFooterItem(int footerIndex) {
    if (footerIndex == 0 && widget.isLoading) {
      return widget.loadingWidget ?? _buildDefaultLoadingWidget();
    }

    if (footerIndex == 0 && widget.hasMoreData && _isLoadingMore) {
      return _buildLoadMoreWidget();
    }

    if (footerIndex == 0 && !widget.hasMoreData && widget.items.isNotEmpty) {
      return _buildEndOfListWidget();
    }

    return const SizedBox.shrink();
  }

  Widget _buildDefaultLoadingWidget() {
    return Container(
      padding: EdgeInsets.all(UIConstants.spacingXL),
      child: Center(
        child: Column(
          children: [
            const CircularProgressIndicator(),
            AppSpacing.vertical(UIConstants.spacingM),
            Text(
              'جاري التحميل...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadMoreWidget() {
    return Container(
      padding: EdgeInsets.all(UIConstants.spacingL),
      child: Center(
        child: Column(
          children: [
            const CircularProgressIndicator(),
            AppSpacing.vertical(UIConstants.spacingS),
            Text(
              'جاري تحميل المزيد...',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEndOfListWidget() {
    return Container(
      padding: EdgeInsets.all(UIConstants.spacingL),
      child: Center(
        child: Text(
          'تم عرض جميع العناصر',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    if (widget.emptyWidget != null) {
      return widget.emptyWidget!;
    }

    return Container(
      padding: EdgeInsets.all(UIConstants.spacingXL),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.inbox,
              size: UIConstants.iconXXL,
              color: AppTheme.textHintColor,
            ),
            AppSpacing.vertical(UIConstants.spacingL),
            Text(
              widget.emptyMessage ?? 'لا توجد عناصر للعرض',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    if (widget.errorWidget != null) {
      return widget.errorWidget!;
    }

    return Container(
      padding: EdgeInsets.all(UIConstants.spacingXL),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: UIConstants.iconXXL,
              color: AppTheme.errorColor,
            ),
            AppSpacing.vertical(UIConstants.spacingL),
            Text(
              widget.errorMessage ?? 'حدث خطأ في التحميل',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.errorColor,
                  ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.vertical(UIConstants.spacingL),
            AppButton(
              text: 'حاول مرة أخرى',
              type: AppButtonType.primary,
              onPressed: widget.onRetry,
            ),
          ],
        ),
      ),
    );
  }

  int _getFooterItemCount() {
    if (widget.items.isEmpty) return 0;
    if (widget.isLoading) return 1;
    if (widget.hasMoreData && _isLoadingMore) return 1;
    if (!widget.hasMoreData) return 1;
    return 0;
  }
}

/// Refresh indicator wrapper for paginated lists
class RefreshablePaginatedList<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Future<void> Function() onRefresh;
  final VoidCallback? onLoadMore;
  final bool hasMoreData;
  final bool isLoading;
  final String? emptyMessage;
  final Widget? emptyWidget;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final EdgeInsets? padding;
  final ScrollController? scrollController;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final int crossAxisCount;
  final double childAspectRatio;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final bool useGridView;

  const RefreshablePaginatedList({
    Key? key,
    required this.items,
    required this.itemBuilder,
    required this.onRefresh,
    this.onLoadMore,
    this.hasMoreData = false,
    this.isLoading = false,
    this.emptyMessage,
    this.emptyWidget,
    this.loadingWidget,
    this.errorWidget,
    this.errorMessage,
    this.onRetry,
    this.padding,
    this.scrollController,
    this.shrinkWrap = false,
    this.physics,
    this.crossAxisCount = 1,
    this.childAspectRatio = 1.0,
    this.crossAxisSpacing = UIConstants.spacingM,
    this.mainAxisSpacing = UIConstants.spacingM,
    this.useGridView = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: PaginatedList<T>(
        items: items,
        itemBuilder: itemBuilder,
        onLoadMore: onLoadMore,
        hasMoreData: hasMoreData,
        isLoading: isLoading,
        emptyMessage: emptyMessage,
        emptyWidget: emptyWidget,
        loadingWidget: loadingWidget,
        errorWidget: errorWidget,
        errorMessage: errorMessage,
        onRetry: onRetry,
        padding: padding,
        scrollController: scrollController,
        shrinkWrap: shrinkWrap,
        physics: physics,
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
        useGridView: useGridView,
      ),
    );
  }
}

/// Lazy loading image widget for better performance
class LazyImage extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;

  const LazyImage({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
  }) : super(key: key);

  @override
  State<LazyImage> createState() => _LazyImageState();
}

class _LazyImageState extends State<LazyImage> {
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius,
        color: AppTheme.backgroundColor,
      ),
      child: ClipRRect(
        borderRadius: widget.borderRadius ?? BorderRadius.zero,
        child: _hasError
            ? (widget.errorWidget ?? _buildDefaultErrorWidget())
            : Image.network(
                widget.imageUrl,
                fit: widget.fit,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }
                  return widget.placeholder ?? _buildDefaultPlaceholder();
                },
                errorBuilder: (context, error, stackTrace) {
                  _hasError = true;
                  return widget.errorWidget ?? _buildDefaultErrorWidget();
                },
              ),
      ),
    );
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      color: AppTheme.backgroundColor,
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
        ),
      ),
    );
  }

  Widget _buildDefaultErrorWidget() {
    return Container(
      color: AppTheme.backgroundColor,
      child: Center(
        child: Icon(
          Icons.broken_image,
          color: AppTheme.textHintColor,
          size: UIConstants.iconL,
        ),
      ),
    );
  }
}
