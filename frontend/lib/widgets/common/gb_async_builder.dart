import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/design_system.dart';
import 'gb_loading_indicator.dart';
import 'gb_button.dart';

/// Async builder widget that handles loading, error, and empty states
///
/// Usage:
/// ```dart
/// GBAsyncBuilder<List<Donation>>(
///   future: donationProvider.loadDonations(),
///   builder: (context, data) {
///     return ListView.builder(
///       itemCount: data.length,
///       itemBuilder: (context, index) => DonationCard(data[index]),
///     );
///   },
/// )
/// ```
class GBAsyncBuilder<T> extends StatelessWidget {
  final Future<T>? future;
  final T? initialData;
  final Widget Function(BuildContext context, T data) builder;
  final Widget Function(BuildContext context, Object error)? errorBuilder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(BuildContext context)? emptyBuilder;
  final VoidCallback? onRetry;
  final bool Function(T data)? isEmpty;
  final String? loadingMessage;
  final String? emptyMessage;

  const GBAsyncBuilder({
    Key? key,
    this.future,
    this.initialData,
    required this.builder,
    this.errorBuilder,
    this.loadingBuilder,
    this.emptyBuilder,
    this.onRetry,
    this.isEmpty,
    this.loadingMessage,
    this.emptyMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      initialData: initialData,
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingBuilder?.call(context) ?? _buildDefaultLoading(context);
        }

        // Error state
        if (snapshot.hasError) {
          return errorBuilder?.call(context, snapshot.error!) ??
              _buildDefaultError(context, snapshot.error!);
        }

        // Empty state
        if (snapshot.hasData) {
          final data = snapshot.data as T;
          if (isEmpty?.call(data) ?? _isDataEmpty(data)) {
            return emptyBuilder?.call(context) ?? _buildDefaultEmpty(context);
          }
          return builder(context, data);
        }

        // No data state
        return _buildDefaultEmpty(context);
      },
    );
  }

  bool _isDataEmpty(T data) {
    if (data is List) return data.isEmpty;
    if (data is Map) return data.isEmpty;
    if (data is String) return data.isEmpty;
    return data == null;
  }

  Widget _buildDefaultLoading(BuildContext context) {
    return GBLoadingIndicator(
      message: loadingMessage ?? 'Loading...',
    );
  }

  Widget _buildDefaultError(BuildContext context, Object error) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.spaceXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: DesignSystem.error,
            ),
            const SizedBox(height: DesignSystem.spaceL),
            Text(
              'Something went wrong',
              style: DesignSystem.displaySmall(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DesignSystem.spaceS),
            Text(
              error.toString(),
              style: DesignSystem.bodyMedium(context).copyWith(
                color:
                    isDark ? DesignSystem.neutral400 : DesignSystem.neutral600,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: DesignSystem.spaceL),
              GBButton(
                text: 'Retry',
                variant: GBButtonVariant.primary,
                onPressed: onRetry!,
                leftIcon: Icon(Icons.refresh),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultEmpty(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.spaceXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: isDark ? DesignSystem.neutral600 : DesignSystem.neutral400,
            ),
            const SizedBox(height: DesignSystem.spaceL),
            Text(
              emptyMessage ?? 'No items found',
              style: DesignSystem.bodyLarge(context).copyWith(
                color:
                    isDark ? DesignSystem.neutral400 : DesignSystem.neutral600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// State-based builder for Provider patterns
///
/// Usage:
/// ```dart
/// GBStateBuilder<DonationProvider>(
///   onInit: (provider) => provider.loadDonations(),
///   builder: (context, provider) {
///     if (provider.isLoading && provider.donations.isEmpty) {
///       return GBLoadingIndicator();
///     }
///     return DonationList(provider.donations);
///   },
/// )
/// ```
class GBStateBuilder<T extends ChangeNotifier> extends StatefulWidget {
  final Widget Function(BuildContext context, T provider) builder;
  final void Function(T provider)? onInit;
  final void Function(T provider)? onDispose;
  final bool Function(T previous, T current)? buildWhen;

  const GBStateBuilder({
    Key? key,
    required this.builder,
    this.onInit,
    this.onDispose,
    this.buildWhen,
  }) : super(key: key);

  @override
  State<GBStateBuilder<T>> createState() => _GBStateBuilderState<T>();
}

class _GBStateBuilderState<T extends ChangeNotifier>
    extends State<GBStateBuilder<T>> {
  @override
  void initState() {
    super.initState();
    if (widget.onInit != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final provider = Provider.of<T>(context, listen: false);
        widget.onInit!(provider);
      });
    }
  }

  @override
  void dispose() {
    if (widget.onDispose != null) {
      final provider = Provider.of<T>(context, listen: false);
      widget.onDispose!(provider);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<T>(
      builder: (context, provider, child) {
        return widget.builder(context, provider);
      },
    );
  }
}

/// Full screen loading overlay
class GBLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const GBLoadingOverlay({
    Key? key,
    required this.isLoading,
    required this.child,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: GBLoadingIndicator.overlay(
              message: message,
            ),
          ),
      ],
    );
  }
}
