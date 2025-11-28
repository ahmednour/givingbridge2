import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../core/theme/design_system.dart';
import '../../providers/filter_provider.dart';
import 'gb_filter_chips.dart';

/// Advanced Filter Panel for comprehensive filtering options
class GBAdvancedFilterPanel extends StatefulWidget {
  final VoidCallback? onFiltersChanged;
  final bool showPresets;
  final bool showAdvancedOptions;

  const GBAdvancedFilterPanel({
    Key? key,
    this.onFiltersChanged,
    this.showPresets = true,
    this.showAdvancedOptions = true,
  }) : super(key: key);

  @override
  State<GBAdvancedFilterPanel> createState() => _GBAdvancedFilterPanelState();
}

class _GBAdvancedFilterPanelState extends State<GBAdvancedFilterPanel>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _presetNameController = TextEditingController();
  final TextEditingController _minAmountController = TextEditingController();
  final TextEditingController _maxAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: widget.showAdvancedOptions ? 3 : 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _presetNameController.dispose();
    _minAmountController.dispose();
    _maxAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FilterProvider>(
      builder: (context, filterProvider, child) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(DesignSystem.radiusL),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(filterProvider),
              _buildTabBar(),
              _buildTabBarView(filterProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(FilterProvider filterProvider) {
    return Padding(
      padding: const EdgeInsets.all(DesignSystem.spaceL),
      child: Row(
        children: [
          Icon(
            Icons.filter_list,
            color: DesignSystem.primaryBlue,
            size: DesignSystem.iconSizeMedium,
          ),
          const SizedBox(width: DesignSystem.spaceM),
          Text(
            'Advanced Filters',
            style: DesignSystem.headlineSmall(context).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          if (filterProvider.hasActiveFilters) ...[
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
            TextButton(
              onPressed: () {
                filterProvider.clearFilters();
                widget.onFiltersChanged?.call();
              },
              child: Text(AppLocalizations.of(context)!.clearAll),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      labelColor: DesignSystem.primaryBlue,
      unselectedLabelColor: DesignSystem.textSecondary,
      indicatorColor: DesignSystem.primaryBlue,
      tabs: [
        const Tab(text: 'Basic Filters'),
        if (widget.showPresets) const Tab(text: 'Presets'),
        if (widget.showAdvancedOptions) const Tab(text: 'Advanced'),
      ],
    );
  }

  Widget _buildTabBarView(FilterProvider filterProvider) {
    return SizedBox(
      height: 400,
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildBasicFilters(filterProvider),
          if (widget.showPresets) _buildPresets(filterProvider),
          if (widget.showAdvancedOptions) _buildAdvancedFilters(filterProvider),
        ],
      ),
    );
  }

  Widget _buildBasicFilters(FilterProvider filterProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignSystem.spaceL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Categories
          GBFilterChips<String>(
            label: 'Categories',
            options: [
              GBFilterOption(
                value: 'food',
                label: 'Food',
                icon: Icons.restaurant,
                color: DesignSystem.success,
              ),
              GBFilterOption(
                value: 'clothes',
                label: 'Clothes',
                icon: Icons.checkroom,
                color: DesignSystem.accentPink,
              ),
              GBFilterOption(
                value: 'books',
                label: 'Books',
                icon: Icons.menu_book,
                color: DesignSystem.accentPurple,
              ),
              GBFilterOption(
                value: 'electronics',
                label: 'Electronics',
                icon: Icons.devices,
                color: DesignSystem.info,
              ),
              GBFilterOption(
                value: 'other',
                label: 'Other',
                icon: Icons.category,
                color: DesignSystem.neutral500,
              ),
            ],
            selectedValues: filterProvider.selectedCategories,
            onChanged: (values) {
              filterProvider.setCategories(values);
              widget.onFiltersChanged?.call();
            },
          ),
          const SizedBox(height: DesignSystem.spaceXL),

          // Status
          GBFilterChips<String>(
            label: 'Status',
            options: [
              GBFilterOption(
                value: 'available',
                label: 'Available',
                icon: Icons.check_circle,
                color: DesignSystem.success,
              ),
              GBFilterOption(
                value: 'pending',
                label: 'Pending',
                icon: Icons.hourglass_empty,
                color: DesignSystem.warning,
              ),
              GBFilterOption(
                value: 'completed',
                label: 'Completed',
                icon: Icons.done_all,
                color: DesignSystem.info,
              ),
              GBFilterOption(
                value: 'cancelled',
                label: 'Cancelled',
                icon: Icons.cancel,
                color: DesignSystem.error,
              ),
            ],
            selectedValues: filterProvider.selectedStatuses,
            onChanged: (values) {
              filterProvider.setStatuses(values);
              widget.onFiltersChanged?.call();
            },
          ),
          const SizedBox(height: DesignSystem.spaceXL),

          // Locations
          GBFilterChips<String>(
            label: 'Locations',
            options: [
              GBFilterOption(value: 'new_york', label: 'New York'),
              GBFilterOption(value: 'los_angeles', label: 'Los Angeles'),
              GBFilterOption(value: 'chicago', label: 'Chicago'),
              GBFilterOption(value: 'houston', label: 'Houston'),
              GBFilterOption(value: 'phoenix', label: 'Phoenix'),
              GBFilterOption(value: 'philadelphia', label: 'Philadelphia'),
            ],
            selectedValues: filterProvider.selectedLocations,
            onChanged: (values) {
              filterProvider.setLocations(values);
              widget.onFiltersChanged?.call();
            },
          ),
          const SizedBox(height: DesignSystem.spaceXL),

          // Date Range
          _buildDateRangeFilter(filterProvider),
          const SizedBox(height: DesignSystem.spaceXL),

          // Amount Range
          _buildAmountRangeFilter(filterProvider),
        ],
      ),
    );
  }

  Widget _buildPresets(FilterProvider filterProvider) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(DesignSystem.spaceL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Save current filters as preset
          Card(
            child: Padding(
              padding: const EdgeInsets.all(DesignSystem.spaceL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Save Current Filters',
                    style: DesignSystem.labelLarge(context).copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: DesignSystem.spaceM),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _presetNameController,
                          decoration: InputDecoration(
                            hintText: l10n.enterPresetName,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: DesignSystem.spaceM),
                      ElevatedButton(
                        onPressed: filterProvider.hasActiveFilters
                            ? () async {
                                if (_presetNameController.text.isNotEmpty) {
                                  await filterProvider.saveFilterPreset(
                                      _presetNameController.text);
                                  _presetNameController.clear();
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                              Text(l10n.filterPresetSaved)),
                                    );
                                  }
                                }
                              }
                            : null,
                        child: Text(l10n.save),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: DesignSystem.spaceL),

          // Saved presets
          Text(
            'Saved Presets',
            style: DesignSystem.labelLarge(context).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: DesignSystem.spaceM),
          Expanded(
            child: filterProvider.savedFilterPresets.isEmpty
                ? Center(
                    child: Text(
                      'No saved presets',
                      style: DesignSystem.bodyMedium(context).copyWith(
                        color: DesignSystem.textSecondary,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: filterProvider.savedFilterPresets.length,
                    itemBuilder: (context, index) {
                      final presetName = filterProvider.savedFilterPresets.keys
                          .elementAt(index);
                      final preset =
                          filterProvider.savedFilterPresets[presetName]!;

                      return Card(
                        child: ListTile(
                          title: Text(presetName),
                          subtitle: Text(_getPresetSummary(preset)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.play_arrow),
                                onPressed: () {
                                  filterProvider.loadFilterPreset(presetName);
                                  widget.onFiltersChanged?.call();
                                },
                                tooltip: 'Apply Preset',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () async {
                                  await filterProvider
                                      .deleteFilterPreset(presetName);
                                },
                                tooltip: l10n.delete,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedFilters(FilterProvider filterProvider) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignSystem.spaceL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Verification and urgency filters
          Row(
            children: [
              Expanded(
                child: CheckboxListTile(
                  title: Text(l10n.verifiedOnly),
                  subtitle: Text(l10n.showOnlyVerifiedItems),
                  value: filterProvider.verifiedOnly,
                  onChanged: (value) {
                    filterProvider.setVerifiedOnly(value ?? false);
                    widget.onFiltersChanged?.call();
                  },
                ),
              ),
              Expanded(
                child: CheckboxListTile(
                  title: Text(l10n.urgentOnly),
                  subtitle: Text(l10n.showOnlyUrgentRequests),
                  value: filterProvider.urgentOnly,
                  onChanged: (value) {
                    filterProvider.setUrgentOnly(value ?? false);
                    widget.onFiltersChanged?.call();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignSystem.spaceL),

          // Distance filter
          Text(
            'Distance',
            style: DesignSystem.labelLarge(context).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: DesignSystem.spaceM),
          GBFilterChips<String>(
            multiSelect: false,
            options: [
              GBFilterOption(value: '5', label: '5 miles'),
              GBFilterOption(value: '10', label: '10 miles'),
              GBFilterOption(value: '25', label: '25 miles'),
              GBFilterOption(value: '50', label: '50 miles'),
              GBFilterOption(value: 'any', label: 'Any distance'),
            ],
            selectedValues: filterProvider.selectedDistance != null
                ? [filterProvider.selectedDistance!]
                : [],
            onChanged: (values) {
              filterProvider
                  .setDistance(values.isNotEmpty ? values.first : null);
              widget.onFiltersChanged?.call();
            },
          ),
          const SizedBox(height: DesignSystem.spaceL),

          // Conditions
          Text(
            'Item Condition',
            style: DesignSystem.labelLarge(context).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: DesignSystem.spaceM),
          GBFilterChips<String>(
            options: [
              GBFilterOption(
                value: 'new',
                label: 'New',
                icon: Icons.new_releases,
                color: DesignSystem.success,
              ),
              GBFilterOption(
                value: 'like_new',
                label: 'Like New',
                icon: Icons.star,
                color: DesignSystem.info,
              ),
              GBFilterOption(
                value: 'good',
                label: 'Good',
                icon: Icons.thumb_up,
                color: DesignSystem.warning,
              ),
              GBFilterOption(
                value: 'fair',
                label: 'Fair',
                icon: Icons.thumbs_up_down,
                color: DesignSystem.neutral500,
              ),
            ],
            selectedValues: filterProvider.selectedConditions,
            onChanged: (values) {
              filterProvider.setConditions(values);
              widget.onFiltersChanged?.call();
            },
          ),
          const SizedBox(height: DesignSystem.spaceL),

          // Sort options
          _buildSortOptions(filterProvider),
        ],
      ),
    );
  }

  Widget _buildDateRangeFilter(FilterProvider filterProvider) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Date Range',
              style: DesignSystem.labelLarge(context).copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            if (filterProvider.startDate != null ||
                filterProvider.endDate != null)
              TextButton(
                onPressed: () {
                  filterProvider.clearDateRange();
                  widget.onFiltersChanged?.call();
                },
                child: Text(l10n.clear),
              ),
          ],
        ),
        const SizedBox(height: DesignSystem.spaceM),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: filterProvider.startDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    filterProvider.setDateRange(date, filterProvider.endDate);
                    widget.onFiltersChanged?.call();
                  }
                },
                child: Text(
                  filterProvider.startDate != null
                      ? 'From: ${_formatDate(filterProvider.startDate!)}'
                      : 'Start Date',
                ),
              ),
            ),
            const SizedBox(width: DesignSystem.spaceM),
            Expanded(
              child: OutlinedButton(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: filterProvider.endDate ?? DateTime.now(),
                    firstDate: filterProvider.startDate ?? DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    filterProvider.setDateRange(filterProvider.startDate, date);
                    widget.onFiltersChanged?.call();
                  }
                },
                child: Text(
                  filterProvider.endDate != null
                      ? 'To: ${_formatDate(filterProvider.endDate!)}'
                      : 'End Date',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAmountRangeFilter(FilterProvider filterProvider) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Amount Range',
              style: DesignSystem.labelLarge(context).copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            if (filterProvider.minAmount != null ||
                filterProvider.maxAmount != null)
              TextButton(
                onPressed: () {
                  filterProvider.clearAmountRange();
                  _minAmountController.clear();
                  _maxAmountController.clear();
                  widget.onFiltersChanged?.call();
                },
                child: Text(l10n.clear),
              ),
          ],
        ),
        const SizedBox(height: DesignSystem.spaceM),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _minAmountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.minAmount,
                  prefixText: '\$',
                  border: const OutlineInputBorder(),
                ),
                onChanged: (value) {
                  final amount = double.tryParse(value);
                  filterProvider.setAmountRange(
                      amount, filterProvider.maxAmount);
                  widget.onFiltersChanged?.call();
                },
              ),
            ),
            const SizedBox(width: DesignSystem.spaceM),
            Expanded(
              child: TextField(
                controller: _maxAmountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.maxAmount,
                  prefixText: '\$',
                  border: const OutlineInputBorder(),
                ),
                onChanged: (value) {
                  final amount = double.tryParse(value);
                  filterProvider.setAmountRange(
                      filterProvider.minAmount, amount);
                  widget.onFiltersChanged?.call();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSortOptions(FilterProvider filterProvider) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sort Options',
          style: DesignSystem.labelLarge(context).copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: DesignSystem.spaceM),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: filterProvider.sortBy,
                decoration: InputDecoration(
                  labelText: l10n.sortBy,
                  border: const OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(
                      value: 'createdAt', child: Text(l10n.dateCreated)),
                  DropdownMenuItem(
                      value: 'updatedAt', child: Text(l10n.lastUpdated)),
                  DropdownMenuItem(value: 'title', child: Text(l10n.title)),
                  DropdownMenuItem(value: 'amount', child: Text(l10n.quantity)),
                  DropdownMenuItem(
                      value: 'location', child: Text(l10n.location)),
                ],
                onChanged: (value) {
                  if (value != null) {
                    filterProvider.setSort(value, filterProvider.sortOrder);
                    widget.onFiltersChanged?.call();
                  }
                },
              ),
            ),
            const SizedBox(width: DesignSystem.spaceM),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: filterProvider.sortOrder,
                decoration: InputDecoration(
                  labelText: l10n.order,
                  border: const OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(value: 'desc', child: Text(l10n.descending)),
                  DropdownMenuItem(value: 'asc', child: Text(l10n.ascending)),
                ],
                onChanged: (value) {
                  if (value != null) {
                    filterProvider.setSort(filterProvider.sortBy, value);
                    widget.onFiltersChanged?.call();
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  String _getPresetSummary(Map<String, dynamic> preset) {
    final List<String> parts = [];

    if (preset['categories'] != null &&
        (preset['categories'] as List).isNotEmpty) {
      parts.add('${(preset['categories'] as List).length} categories');
    }
    if (preset['statuses'] != null && (preset['statuses'] as List).isNotEmpty) {
      parts.add('${(preset['statuses'] as List).length} statuses');
    }
    if (preset['startDate'] != null || preset['endDate'] != null) {
      parts.add('date range');
    }
    if (preset['minAmount'] != null || preset['maxAmount'] != null) {
      parts.add('amount range');
    }

    return parts.isEmpty ? 'No filters' : parts.join(', ');
  }
}
