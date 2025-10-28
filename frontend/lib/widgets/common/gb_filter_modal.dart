import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/design_system.dart';
import '../../providers/filter_provider.dart';
import 'gb_advanced_filter_panel.dart';

/// Modal dialog for mobile-friendly filtering
class GBFilterModal extends StatefulWidget {
  final VoidCallback? onFiltersChanged;

  const GBFilterModal({
    Key? key,
    this.onFiltersChanged,
  }) : super(key: key);

  static Future<void> show(BuildContext context, {VoidCallback? onFiltersChanged}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GBFilterModal(onFiltersChanged: onFiltersChanged),
    );
  }

  @override
  State<GBFilterModal> createState() => _GBFilterModalState();
}

class _GBFilterModalState extends State<GBFilterModal> {
  @override
  Widget build(BuildContext context) {
    return Consumer<FilterProvider>(
      builder: (context, filterProvider, child) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(DesignSystem.radiusXL),
              topRight: Radius.circular(DesignSystem.radiusXL),
            ),
          ),
          child: Column(
            children: [
              _buildHeader(context, filterProvider),
              Expanded(
                child: GBAdvancedFilterPanel(
                  onFiltersChanged: widget.onFiltersChanged,
                  showPresets: true,
                  showAdvancedOptions: true,
                ),
              ),
              _buildFooter(context, filterProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, FilterProvider filterProvider) {
    return Container(
      padding: const EdgeInsets.all(DesignSystem.spaceL),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: DesignSystem.getBorderColor(context),
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Filter Options',
            style: DesignSystem.headlineSmall(context).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          if (filterProvider.hasActiveFilters)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DesignSystem.spaceM,
                vertical: DesignSystem.spaceS,
              ),
              decoration: BoxDecoration(
                color: DesignSystem.primaryBlue,
                borderRadius: BorderRadius.circular(DesignSystem.radiusPill),
              ),
              child: Text(
                '${filterProvider.activeFiltersCount} active',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(width: DesignSystem.spaceM),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, FilterProvider filterProvider) {
    return Container(
      padding: const EdgeInsets.all(DesignSystem.spaceL),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: DesignSystem.getBorderColor(context),
          ),
        ),
      ),
      child: Row(
        children: [
          if (filterProvider.hasActiveFilters)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  filterProvider.clearFilters();
                  widget.onFiltersChanged?.call();
                },
                child: const Text('Clear All'),
              ),
            ),
          if (filterProvider.hasActiveFilters) const SizedBox(width: DesignSystem.spaceM),
          Expanded(
            flex: filterProvider.hasActiveFilters ? 2 : 1,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onFiltersChanged?.call();
              },
              child: Text(
                filterProvider.hasActiveFilters
                    ? 'Apply Filters (${filterProvider.activeFiltersCount})'
                    : 'Close',
              ),
            ),
          ),
        ],
      ),
    );
  }
}