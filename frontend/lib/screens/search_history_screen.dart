import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/filter_provider.dart';
import '../services/search_service.dart';

/// Screen for managing search history and viewing search analytics
class SearchHistoryScreen extends StatefulWidget {
  const SearchHistoryScreen({super.key});

  @override
  State<SearchHistoryScreen> createState() => _SearchHistoryScreenState();
}

class _SearchHistoryScreenState extends State<SearchHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  SearchAnalytics? _searchAnalytics;
  bool _isLoadingAnalytics = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final filterProvider = Provider.of<FilterProvider>(context, listen: false);
    
    // Load search history and popular terms
    await Future.wait([
      filterProvider.loadSearchHistory(),
      filterProvider.loadPopularTerms(),
    ]);
    
    // Load analytics if user is admin (optional)
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() {
      _isLoadingAnalytics = true;
    });

    try {
      final searchService = SearchService();
      final analytics = await searchService.getSearchAnalytics(days: 30);
      
      if (mounted) {
        setState(() {
          _searchAnalytics = analytics;
        });
      }
    } catch (e) {
      // Analytics might not be available for non-admin users
      if (mounted) {
        setState(() {
          _searchAnalytics = null;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingAnalytics = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search History'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'History', icon: Icon(Icons.history)),
            Tab(text: 'Popular', icon: Icon(Icons.trending_up)),
            Tab(text: 'Analytics', icon: Icon(Icons.analytics)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHistoryTab(),
          _buildPopularTab(),
          _buildAnalyticsTab(),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return Consumer<FilterProvider>(
      builder: (context, filterProvider, child) {
        if (filterProvider.isLoadingHistory) {
          return const Center(child: CircularProgressIndicator());
        }

        if (filterProvider.searchHistory.isEmpty) {
          return _buildEmptyState(
            icon: Icons.history,
            title: 'No Search History',
            subtitle: 'Your recent searches will appear here',
          );
        }

        return Column(
          children: [
            // Clear all button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: OutlinedButton.icon(
                onPressed: () => _showClearHistoryDialog(filterProvider),
                icon: const Icon(Icons.clear_all),
                label: const Text('Clear All History'),
              ),
            ),
            
            // History list
            Expanded(
              child: ListView.builder(
                itemCount: filterProvider.searchHistory.length,
                itemBuilder: (context, index) {
                  final historyItem = filterProvider.searchHistory[index];
                  return _buildHistoryItem(historyItem, filterProvider);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPopularTab() {
    return Consumer<FilterProvider>(
      builder: (context, filterProvider, child) {
        if (filterProvider.popularTerms.isEmpty) {
          return _buildEmptyState(
            icon: Icons.trending_up,
            title: 'No Popular Searches',
            subtitle: 'Popular search terms will appear here',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filterProvider.popularTerms.length,
          itemBuilder: (context, index) {
            final popularTerm = filterProvider.popularTerms[index];
            return _buildPopularTermItem(popularTerm, filterProvider);
          },
        );
      },
    );
  }

  Widget _buildAnalyticsTab() {
    if (_isLoadingAnalytics) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchAnalytics == null) {
      return _buildEmptyState(
        icon: Icons.analytics,
        title: 'Analytics Not Available',
        subtitle: 'Search analytics are only available for administrators',
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overview cards
          Row(
            children: [
              Expanded(
                child: _buildAnalyticsCard(
                  'Total Searches',
                  _searchAnalytics!.totalSearches.toString(),
                  Icons.search,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildAnalyticsCard(
                  'Unique Users',
                  _searchAnalytics!.uniqueUsers.toString(),
                  Icons.people,
                  Colors.green,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildAnalyticsCard(
                  'Avg per User',
                  _searchAnalytics!.averageSearchesPerUser.toString(),
                  Icons.person,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildAnalyticsCard(
                  'Top Terms',
                  _searchAnalytics!.topTerms.length.toString(),
                  Icons.trending_up,
                  Colors.purple,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Top search terms
          Text(
            'Top Search Terms (Last 30 Days)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 16),
          
          ...(_searchAnalytics!.topTerms.take(10).map(
            (term) => _buildAnalyticsTermItem(term),
          )),
          
          const SizedBox(height: 24),
          
          // Search trends
          if (_searchAnalytics!.searchTrends.isNotEmpty) ...[
            Text(
              'Search Trends',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Container(
              height: 200,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'Search trends chart would go here\n(Chart implementation not included in this task)',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHistoryItem(SearchHistoryItem historyItem, FilterProvider filterProvider) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: const Icon(Icons.history),
        title: Text(historyItem.term),
        subtitle: Text(_formatDate(historyItem.lastSearched)),
        trailing: IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            filterProvider.selectSearchHistoryItem(historyItem);
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  Widget _buildPopularTermItem(PopularSearchTerm popularTerm, FilterProvider filterProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.trending_up),
        title: Text(popularTerm.searchTerm),
        subtitle: Text('${popularTerm.searchCount} searches'),
        trailing: IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            filterProvider.selectPopularTerm(popularTerm);
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  Widget _buildAnalyticsCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTermItem(PopularSearchTerm term) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              term.searchTerm,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${term.searchCount}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _showClearHistoryDialog(FilterProvider filterProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Search History'),
        content: const Text(
          'Are you sure you want to clear all your search history? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await filterProvider.clearSearchHistory();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success 
                ? 'Search history cleared successfully'
                : 'Failed to clear search history',
            ),
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}