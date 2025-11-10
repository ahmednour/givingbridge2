import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/design_system.dart';
import '../../providers/filter_provider.dart';
import '../../l10n/app_localizations.dart';

/// Compact filter bar for quick access to common filters
class GBFilterBar extends StatelessWidget {
  final VoidCallback? onAdvancedFiltersPressed;
  final VoidCallback? onFiltersChanged;
  final bool showAdvancedButton;

  const GBFilterBar({
    Key? key,
    this.onAdvancedFiltersPressed,
    this.onFiltersChanged,
    this.showAdvancedButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<FilterProvider>(
      builder: (context, filterProvider, child) {
        return Container(
          padding: const EdgeInsets.all(DesignSystem.spaceM),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(DesignSystem.radiusM),
            border: Border.all(
              color: DesignSystem.getBorderColor(context),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopRow(context, filterProvider),
              if (filterProvider.hasActiveFilters) ...[
                const SizedBox(height: DesignSystem.spaceM),
                _buildActiveFilters(context, filterProvider),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopRow(BuildContext context, FilterProvider filterProvider) {
    return Row(
      children: [
        Icon(
          Icons.filter_list,
          color: DesignSystem.primaryBlue,
          size: DesignSystem.iconSizeSmall,
        ),
        const SizedBox(width: DesignSystem.spaceS),
        Text(
          'Filters',
          style: DesignSystem.labelLarge(context).copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        if (filterProvider.hasActiveFilters) ...[
          const SizedBox(width: DesignSystem.spaceS),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignSystem.spaceS,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: DesignSystem.primaryBlue,
              borderRadius: BorderRadius.circular(DesignSystem.radiusPill),
            ),
            child: Text(
              filterProvider.activeFiltersCount.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
        const Spacer(),
        if (showAdvancedButton)
          OutlinedButton.icon(
            onPressed: onAdvancedFiltersPressed,
            icon: const Icon(Icons.tune, size: 16),
            label: Text(AppLocalizations.of(context)!.advanced),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: DesignSystem.spaceM,
                vertical: DesignSystem.spaceS,
              ),
            ),
          ),
        if (filterProvider.hasActiveFilters) ...[
          const SizedBox(width: DesignSystem.spaceS),
          TextButton(
            onPressed: () {
              filterProvider.clearFilters();
              onFiltersChanged?.call();
            },
            child: Text(AppLocalizations.of(context)!.clearAll),
          ),
        ],
      ],
    );
  } 
 Widget _buildActiveFilters(BuildContext context, FilterProvider filterProvider) {
    final List<Widget> filterChips = [];

    // Search query
    if (filterProvider.searchQuery.isNotEmpty) {
      filterChips.add(_buildFilterChip(
        context,
        'Search: "${filterProvider.searchQuery}"',
        () {
          filterProvider.clearSearch();
          onFiltersChanged?.call();
        },
      ));
    }

    // Categories
    for (final category in filterProvider.selectedCategories) {
      filterChips.add(_buildFilterChip(
        context,
        'Category: $category',
        () {
          filterProvider.removeCategory(category);
          onFiltersChanged?.call();
        },
      ));
    }

    // Statuses
    for (final status in filterProvider.selectedStatuses) {
      filterChips.add(_buildFilterChip(
        context,
        'Status: $status',
        () {
          filterProvider.removeStatus(status);
          onFiltersChanged?.call();
        },
      ));
    }

    // Locations
    for (final location in filterProvider.selectedLocations) {
      filterChips.add(_buildFilterChip(
        context,
        'Location: $location',
        () {
          filterProvider.removeLocation(location);
          onFiltersChanged?.call();
        },
      ));
    }

    // Date range
    if (filterProvider.startDate != null || filterProvider.endDate != null) {
      String dateText = 'Date: ';
      if (filterProvider.startDate != null && filterProvider.endDate != null) {
        dateText += '${_formatDate(filterProvider.startDate!)} - ${_formatDate(filterProvider.endDate!)}';
      } else if (filterProvider.startDate != null) {
        dateText += 'From ${_formatDate(filterProvider.startDate!)}';
      } else {
        dateText += 'Until ${_formatDate(filterProvider.endDate!)}';
      }
      
      filterChips.add(_buildFilterChip(
        context,
        dateText,
        () {
          filterProvider.clearDateRange();
          onFiltersChanged?.call();
        },
      ));
    }

    // Amount range
    if (filterProvider.minAmount != null || filterProvider.maxAmount != null) {
      String amountText = 'Amount: ';
      if (filterProvider.minAmount != null && filterProvider.maxAmount != null) {
        amountText += '\$${filterProvider.minAmount!.toStringAsFixed(0)} - \$${filterProvider.maxAmount!.toStringAsFixed(0)}';
      } else if (filterProvider.minAmount != null) {
        amountText += 'Min \$${filterProvider.minAmount!.toStringAsFixed(0)}';
      } else {
        amountText += 'Max \$${filterProvider.maxAmount!.toStringAsFixed(0)}';
      }
      
      filterChips.add(_buildFilterChip(
        context,
        amountText,
        () {
          filterProvider.clearAmountRange();
          onFiltersChanged?.call();
        },
      ));
    }

    // Verified only
    if (filterProvider.verifiedOnly) {
      filterChips.add(_buildFilterChip(
        context,
        'Verified Only',
        () {
          filterProvider.setVerifiedOnly(false);
          onFiltersChanged?.call();
        },
      ));
    }

    // Urgent only
    if (filterProvider.urgentOnly) {
      filterChips.add(_buildFilterChip(
        context,
        'Urgent Only',
        () {
          filterProvider.setUrgentOnly(false);
          onFiltersChanged?.call();
        },
      ));
    }

    // Distance
    if (filterProvider.selectedDistance != null) {
      filterChips.add(_buildFilterChip(
        context,
        'Distance: ${filterProvider.selectedDistance} miles',
        () {
          filterProvider.setDistance(null);
          onFiltersChanged?.call();
        },
      ));
    }

    return Wrap(
      spacing: DesignSystem.spaceS,
      runSpacing: DesignSystem.spaceS,
      children: filterChips,
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, VoidCallback onRemove) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignSystem.spaceM,
        vertical: DesignSystem.spaceS,
      ),
      decoration: BoxDecoration(
        color: DesignSystem.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(DesignSystem.radiusPill),
        border: Border.all(
          color: DesignSystem.primaryBlue.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: DesignSystem.bodySmall(context).copyWith(
              color: DesignSystem.primaryBlue,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: DesignSystem.spaceS),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close,
              size: 14,
              color: DesignSystem.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}