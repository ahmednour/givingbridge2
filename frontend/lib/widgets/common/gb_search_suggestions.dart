import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/filter_provider.dart';
import '../../l10n/app_localizations.dart';

/// Widget that displays search suggestions, history, and popular terms
class GBSearchSuggestions extends StatefulWidget {
  final TextEditingController searchController;
  final String searchType;
  final VoidCallback? onSuggestionSelected;
  final bool showHistory;
  final bool showPopular;
  final double maxHeight;

  const GBSearchSuggestions({
    super.key,
    required this.searchController,
    this.searchType = 'all',
    this.onSuggestionSelected,
    this.showHistory = true,
    this.showPopular = true,
    this.maxHeight = 300,
  });

  @override
  State<GBSearchSuggestions> createState() => _GBSearchSuggestionsState();
}

class _GBSearchSuggestionsState extends State<GBSearchSuggestions> {
  bool _isExpanded = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.searchController.addListener(_onSearchChanged);
    _focusNode.addListener(_onFocusChanged);

    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final filterProvider =
          Provider.of<FilterProvider>(context, listen: false);
      filterProvider.loadSearchHistory();
      filterProvider.loadPopularTerms();
    });
  }

  @override
  void dispose() {
    widget.searchController.removeListener(_onSearchChanged);
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = widget.searchController.text;
    final filterProvider = Provider.of<FilterProvider>(context, listen: false);

    if (query.length >= 2) {
      filterProvider.getSearchSuggestions(query, type: widget.searchType);
      setState(() {
        _isExpanded = true;
      });
    } else {
      filterProvider.clearSearchSuggestions();
      setState(() {
        _isExpanded = widget.showHistory || widget.showPopular;
      });
    }
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      setState(() {
        _isExpanded = true;
      });
    } else {
      // Delay hiding to allow for tap on suggestions
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) {
          setState(() {
            _isExpanded = false;
          });
        }
      });
    }
  }

  void _selectSuggestion(String text) {
    widget.searchController.text = text;
    final filterProvider = Provider.of<FilterProvider>(context, listen: false);
    filterProvider.setSearchQuery(text);

    setState(() {
      _isExpanded = false;
    });

    widget.onSuggestionSelected?.call();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Search input field
        TextField(
          controller: widget.searchController,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!
                .searchDonationsCategoriesLocations,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: widget.searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      widget.searchController.clear();
                      final filterProvider =
                          Provider.of<FilterProvider>(context, listen: false);
                      filterProvider.clearSearch();
                      filterProvider.clearSearchSuggestions();
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
          ),
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              _selectSuggestion(value.trim());
            }
          },
        ),

        // Suggestions dropdown
        if (_isExpanded)
          Container(
            constraints: BoxConstraints(maxHeight: widget.maxHeight),
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .outline
                    .withValues(alpha: 0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Consumer<FilterProvider>(
              builder: (context, filterProvider, child) {
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Search suggestions
                      if (filterProvider.searchSuggestions.isNotEmpty) ...[
                        _buildSectionHeader('Suggestions'),
                        ...filterProvider.searchSuggestions.map(
                          (suggestion) => _buildSuggestionItem(
                            suggestion.text,
                            icon: _getIconForSuggestionType(suggestion.type),
                            subtitle: suggestion.location,
                            onTap: () => _selectSuggestion(suggestion.text),
                          ),
                        ),
                      ],

                      // Loading indicator for suggestions
                      if (filterProvider.isLoadingSuggestions)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),

                      // Search history
                      if (widget.showHistory &&
                          filterProvider.searchHistory.isNotEmpty &&
                          widget.searchController.text.length < 2) ...[
                        _buildSectionHeader(
                          'Recent Searches',
                          action: TextButton(
                            onPressed: () async {
                              final success =
                                  await filterProvider.clearSearchHistory();
                              if (success && mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(AppLocalizations.of(context)!
                                        .searchHistoryCleared),
                                  ),
                                );
                              }
                            },
                            child: Text(AppLocalizations.of(context)!.clear),
                          ),
                        ),
                        ...filterProvider.searchHistory.take(5).map(
                              (historyItem) => _buildSuggestionItem(
                                historyItem.term,
                                icon: Icons.history,
                                subtitle: _formatDate(historyItem.lastSearched),
                                onTap: () =>
                                    _selectSuggestion(historyItem.term),
                              ),
                            ),
                      ],

                      // Popular search terms
                      if (widget.showPopular &&
                          filterProvider.popularTerms.isNotEmpty &&
                          widget.searchController.text.length < 2) ...[
                        _buildSectionHeader('Popular Searches'),
                        ...filterProvider.popularTerms.take(5).map(
                              (popularTerm) => _buildSuggestionItem(
                                popularTerm.searchTerm,
                                icon: Icons.trending_up,
                                subtitle: '${popularTerm.searchCount} searches',
                                onTap: () =>
                                    _selectSuggestion(popularTerm.searchTerm),
                              ),
                            ),
                      ],

                      // Empty state
                      if (filterProvider.searchSuggestions.isEmpty &&
                          filterProvider.searchHistory.isEmpty &&
                          filterProvider.popularTerms.isEmpty &&
                          !filterProvider.isLoadingSuggestions &&
                          !filterProvider.isLoadingHistory)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Start typing to see suggestions',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, {Widget? action}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          if (action != null) action,
        ],
      ),
    );
  }

  Widget _buildSuggestionItem(
    String text, {
    required IconData icon,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Icon(
              Icons.north_west,
              size: 16,
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant
                  .withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForSuggestionType(String type) {
    switch (type) {
      case 'donation_title':
        return Icons.card_giftcard;
      case 'user_name':
        return Icons.person;
      case 'location':
        return Icons.location_on;
      default:
        return Icons.search;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
