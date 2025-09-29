import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../widgets/app_button.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';
import '../models/donation.dart';
import '../models/user.dart';

class BrowseDonationsScreen extends StatefulWidget {
  const BrowseDonationsScreen({Key? key}) : super(key: key);

  @override
  _BrowseDonationsScreenState createState() => _BrowseDonationsScreenState();
}

class _BrowseDonationsScreenState extends State<BrowseDonationsScreen> {
  List<Donation> _donations = [];
  List<Donation> _filteredDonations = [];
  bool _isLoading = true;
  String _selectedCategory = 'all';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _categories = [
    {'value': 'all', 'label': 'All', 'icon': Icons.apps},
    {'value': 'food', 'label': 'Food', 'icon': Icons.restaurant},
    {'value': 'clothes', 'label': 'Clothes', 'icon': Icons.checkroom},
    {'value': 'books', 'label': 'Books', 'icon': Icons.menu_book},
    {'value': 'electronics', 'label': 'Electronics', 'icon': Icons.devices},
    {'value': 'other', 'label': 'Other', 'icon': Icons.category},
  ];

  @override
  void initState() {
    super.initState();
    _loadDonations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDonations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.getDonations(available: true);
      if (response.success && response.data != null) {
        setState(() {
          _donations = response.data!;
          _applyFilters();
        });
      } else {
        _showErrorSnackbar(response.error ?? 'Failed to load donations');
      }
    } catch (e) {
      _showErrorSnackbar('Network error: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    List<Donation> filtered = _donations;

    // Filter by category
    if (_selectedCategory != 'all') {
      filtered =
          filtered.where((d) => d.category == _selectedCategory).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((d) {
        return d.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            d.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            d.location.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    setState(() {
      _filteredDonations = filtered;
    });
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _applyFilters();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _applyFilters();
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _requestDonation(Donation donation) async {
    // Show request dialog with optional message
    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      builder: (context) => _RequestDialog(donation: donation),
    );

    if (result != null && result['confirmed'] == true) {
      try {
        final response = await ApiService.createRequest(
          donationId: donation.id.toString(),
          message: result['message'],
        );

        if (response.success) {
          _showSuccessSnackbar('Request sent! The donor will be notified.');
          // Refresh donations to reflect any status changes
          _loadDonations();
        } else {
          _showErrorSnackbar(response.error ?? 'Failed to send request');
        }
      } catch (e) {
        _showErrorSnackbar('Network error: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Browse Donations',
          style: TextStyle(
            color: AppTheme.textPrimaryColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search and Filters
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(AppTheme.spacingL),
            child: Column(
              children: [
                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(AppTheme.radiusL),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: const InputDecoration(
                      hintText: 'Search donations...',
                      prefixIcon: Icon(Icons.search,
                          color: AppTheme.textSecondaryColor),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingL,
                        vertical: AppTheme.spacingM,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppTheme.spacingL),

                // Category Filters
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = _selectedCategory == category['value'];

                      return Container(
                        margin: const EdgeInsets.only(right: AppTheme.spacingM),
                        child: FilterChip(
                          selected: isSelected,
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                category['icon'],
                                size: 16,
                                color: isSelected
                                    ? Colors.white
                                    : AppTheme.textSecondaryColor,
                              ),
                              const SizedBox(width: AppTheme.spacingM),
                              Text(category['label']),
                            ],
                          ),
                          onSelected: (_) =>
                              _onCategorySelected(category['value']),
                          backgroundColor: AppTheme.surfaceColor,
                          selectedColor: AppTheme.primaryColor,
                          checkmarkColor: Colors.white,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppTheme.textPrimaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Donations List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                    ),
                  )
                : _filteredDonations.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadDonations,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(AppTheme.spacingL),
                          itemCount: _filteredDonations.length,
                          itemBuilder: (context, index) {
                            final donation = _filteredDonations[index];
                            return _buildDonationCard(donation, user!);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.volunteer_activism,
              size: 40,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: AppTheme.spacingL),
          const Text(
            'No donations found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            _searchQuery.isNotEmpty || _selectedCategory != 'all'
                ? 'Try adjusting your filters'
                : 'Be the first to make a donation!',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: AppTheme.spacingL),
          AppButton(
            text: 'Refresh',
            onPressed: _loadDonations,
            variant: ButtonVariant.outline,
          ),
        ],
      ),
    );
  }

  Widget _buildDonationCard(Donation donation, User user) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        boxShadow: AppTheme.shadowMD,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image (if available)
          if (donation.imageUrl != null && donation.imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppTheme.radiusL),
                topRight: Radius.circular(AppTheme.radiusL),
              ),
              child: Image.network(
                donation.imageUrl!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 200,
                    color: AppTheme.surfaceColor,
                    child: const Icon(
                      Icons.image_not_supported,
                      size: 48,
                      color: AppTheme.textSecondaryColor,
                    ),
                  );
                },
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category and Condition
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingM,
                        vertical: AppTheme.spacingM,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusL),
                      ),
                      child: Text(
                        donation.categoryDisplayName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingM),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingM,
                        vertical: AppTheme.spacingM,
                      ),
                      decoration: BoxDecoration(
                        color: _getConditionColor(donation.condition)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusL),
                      ),
                      child: Text(
                        donation.conditionDisplayName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _getConditionColor(donation.condition),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppTheme.spacingM),

                // Title
                Text(
                  donation.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),

                const SizedBox(height: AppTheme.spacingM),

                // Description
                Text(
                  donation.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondaryColor,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: AppTheme.spacingM),

                // Donor and Location
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 16,
                      color: AppTheme.textSecondaryColor,
                    ),
                    const SizedBox(width: AppTheme.spacingM),
                    Text(
                      donation.donorName,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingL),
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: AppTheme.textSecondaryColor,
                    ),
                    const SizedBox(width: AppTheme.spacingM),
                    Expanded(
                      child: Text(
                        donation.location,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondaryColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppTheme.spacingL),

                // Action Button (only for receivers)
                if (user.isReceiver)
                  AppButton(
                    text: 'Request Donation',
                    onPressed: () => _requestDonation(donation),
                    size: ButtonSize.small,
                    width: double.infinity,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getConditionColor(String condition) {
    switch (condition) {
      case 'new':
        return Colors.green;
      case 'like-new':
        return Colors.lightGreen;
      case 'good':
        return Colors.orange;
      case 'fair':
        return Colors.red;
      default:
        return AppTheme.textSecondaryColor;
    }
  }
}

class _RequestDialog extends StatefulWidget {
  final Donation donation;

  const _RequestDialog({Key? key, required this.donation}) : super(key: key);

  @override
  _RequestDialogState createState() => _RequestDialogState();
}

class _RequestDialogState extends State<_RequestDialog> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Request Donation'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You are requesting "${widget.donation.title}" from ${widget.donation.donorName}.',
              style: AppTheme.bodyMedium,
            ),
            const SizedBox(height: AppTheme.spacingM),
            TextField(
              controller: _messageController,
              maxLines: 3,
              maxLength: 500,
              decoration: const InputDecoration(
                labelText: 'Message (Optional)',
                hintText: 'Tell the donor why you need this donation...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              'The donor will see your contact information and can approve or decline your request.',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        AppButton(
          text: 'Send Request',
          onPressed: () {
            Navigator.pop(context, {
              'confirmed': true,
              'message': _messageController.text.trim().isEmpty
                  ? null
                  : _messageController.text.trim(),
            });
          },
          size: ButtonSize.small,
        ),
      ],
    );
  }
}
