import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/design_system.dart';
import '../providers/filter_provider.dart';
import '../widgets/common/gb_filter_bar.dart';
import '../widgets/common/gb_advanced_filter_panel.dart';
import '../widgets/common/gb_filter_modal.dart';
import '../widgets/common/gb_search_suggestions.dart';
import '../screens/search_history_screen.dart';
import '../l10n/app_localizations.dart';

/// Example screen demonstrating the enhanced filtering system
class DonationsWithFiltersScreen extends StatefulWidget {
  const DonationsWithFiltersScreen({Key? key}) : super(key: key);

  @override
  State<DonationsWithFiltersScreen> createState() =>
      _DonationsWithFiltersScreenState();
}

class _DonationsWithFiltersScreenState
    extends State<DonationsWithFiltersScreen> {
  bool _showAdvancedFilters = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize the filter provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FilterProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<FilterProvider>(
        builder: (context, filterProvider, child) {
          return Column(
            children: [
              // Search bar
              _buildSearchBar(filterProvider),

              // Filter bar
              Padding(
                padding: const EdgeInsets.all(DesignSystem.spaceM),
                child: GBFilterBar(
                  onAdvancedFiltersPressed: () {
                    if (MediaQuery.of(context).size.width < 768) {
                      // Mobile: Show modal
                      GBFilterModal.show(context,
                          onFiltersChanged: _onFiltersChanged);
                    } else {
                      // Desktop: Toggle panel
                      setState(() {
                        _showAdvancedFilters = !_showAdvancedFilters;
                      });
                    }
                  },
                  onFiltersChanged: _onFiltersChanged,
                ),
              ),

              // Advanced filters panel (desktop only)
              if (_showAdvancedFilters &&
                  MediaQuery.of(context).size.width >= 768)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: DesignSystem.spaceM),
                  child: GBAdvancedFilterPanel(
                    onFiltersChanged: _onFiltersChanged,
                  ),
                ),

              // Results
              Expanded(
                child: _buildResults(filterProvider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(FilterProvider filterProvider) {
    return Container(
      padding: const EdgeInsets.all(DesignSystem.spaceM),
      color: Theme.of(context).cardColor,
      child: Row(
        children: [
          // Search suggestions widget
          Expanded(
            child: GBSearchSuggestions(
              searchController: _searchController,
              searchType: 'donations',
              onSuggestionSelected: _onFiltersChanged,
            ),
          ),

          const SizedBox(width: DesignSystem.spaceS),

          // Search history button
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Search History',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SearchHistoryScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildResults(FilterProvider filterProvider) {
    // This would normally fetch and display filtered results
    // For demo purposes, we'll show the current filter state
    return Padding(
      padding: const EdgeInsets.all(DesignSystem.spaceM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter Results',
            style: DesignSystem.headlineSmall(context).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: DesignSystem.spaceM),
          if (!filterProvider.hasActiveFilters)
            Center(
              child: Text(AppLocalizations.of(context)!.noFiltersApplied),
            )
          else ...[
            Text(
              'Active Filters: ${filterProvider.activeFiltersCount}',
              style: DesignSystem.labelLarge(context).copyWith(
                fontWeight: FontWeight.w600,
                color: DesignSystem.primaryBlue,
              ),
            ),
            const SizedBox(height: DesignSystem.spaceM),
            Expanded(
              child: SingleChildScrollView(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(DesignSystem.spaceL),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Filter Configuration:',
                          style: DesignSystem.labelLarge(context).copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: DesignSystem.spaceM),
                        _buildFilterSummary(filterProvider),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterSummary(FilterProvider filterProvider) {
    final summary = filterProvider.filterSummary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (summary['searchQuery'].isNotEmpty)
          _buildSummaryItem('Search Query', summary['searchQuery']),
        if ((summary['categories'] as List).isNotEmpty)
          _buildSummaryItem(
              'Categories', (summary['categories'] as List).join(', ')),
        if ((summary['statuses'] as List).isNotEmpty)
          _buildSummaryItem(
              'Statuses', (summary['statuses'] as List).join(', ')),
        if ((summary['locations'] as List).isNotEmpty)
          _buildSummaryItem(
              'Locations', (summary['locations'] as List).join(', ')),
        if (summary['startDate'] != null || summary['endDate'] != null)
          _buildSummaryItem('Date Range',
              '${summary['startDate'] ?? 'Any'} to ${summary['endDate'] ?? 'Any'}'),
        if (summary['minAmount'] != null || summary['maxAmount'] != null)
          _buildSummaryItem('Amount Range',
              '\$${summary['minAmount'] ?? 0} - \$${summary['maxAmount'] ?? '∞'}'),
        if (summary['verifiedOnly']) _buildSummaryItem('Verified Only', 'Yes'),
        if (summary['urgentOnly']) _buildSummaryItem('Urgent Only', 'Yes'),
        if (summary['distance'] != null)
          _buildSummaryItem('Distance', '${summary['distance']} miles'),
        _buildSummaryItem(
            'Sort By', '${summary['sortBy']} (${summary['sortOrder']})'),
        _buildSummaryItem('Page Size', summary['pageSize'].toString()),
      ],
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DesignSystem.spaceS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: DesignSystem.bodyMedium(context).copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: DesignSystem.bodyMedium(context),
            ),
          ),
        ],
      ),
    );
  }

  void _onFiltersChanged() {
    // This would normally trigger a data refresh
    // For demo purposes, we'll just rebuild the UI
    setState(() {});
  }
}
