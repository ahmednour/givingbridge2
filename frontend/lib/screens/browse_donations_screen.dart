import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../core/theme/design_system.dart';
import '../core/utils/responsive_utils.dart';
import '../widgets/common/gb_button.dart';
import '../widgets/common/gb_search_bar.dart';
import '../widgets/common/gb_filter_chips.dart';
import '../widgets/common/gb_empty_state.dart';
import '../widgets/common/gb_skeleton_widgets.dart';
import '../widgets/common/web_card.dart';
import '../widgets/common/touch_friendly_widgets.dart';
import '../widgets/rtl/directional_row.dart';
import '../widgets/rtl/directional_column.dart';
import '../widgets/rtl/directional_container.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';
import '../models/donation.dart';
import '../models/user.dart';
import '../l10n/app_localizations.dart';

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
  Timer? _debounce;

  final List<GBFilterOption<String>> _categoryOptions = [
    GBFilterOption(value: 'all', label: 'All', icon: Icons.apps),
    GBFilterOption(value: 'food', label: 'Food', icon: Icons.restaurant),
    GBFilterOption(value: 'clothes', label: 'Clothes', icon: Icons.checkroom),
    GBFilterOption(value: 'books', label: 'Books', icon: Icons.menu_book),
    GBFilterOption(
        value: 'electronics', label: 'Electronics', icon: Icons.devices),
    GBFilterOption(value: 'other', label: 'Other', icon: Icons.category),
  ];
  List<String> _selectedCategories = [];

  @override
  void initState() {
    super.initState();
    _loadDonations();
  }

  @override
  void dispose() {
    _debounce?.cancel();
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
          _donations = response.data!.items;
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

  void _onCategorySelected(List<String> categories) {
    setState(() {
      _selectedCategories = categories;
      _selectedCategory = categories.isEmpty ? 'all' : categories.first;
    });
    _applyFilters();
  }

  void _onSearchChanged(String query) {
    // Cancel previous debounce timer
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Set new debounce timer
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = query;
      });
      _applyFilters();
    });
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: DirectionalRow(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: DesignSystem.spaceM),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: DesignSystem.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: DirectionalRow(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: DesignSystem.spaceM),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: DesignSystem.success,
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
    final localeProvider = Provider.of<LocaleProvider>(context);
    final user = authProvider.user;
    final l10n = AppLocalizations.of(context)!;

    return Directionality(
      textDirection: localeProvider.textDirection,
      child: ResponsiveLayoutBuilder(
        builder: (context, screenSize) {
          return Scaffold(
            backgroundColor: DesignSystem.getBackgroundColor(context),
            body: DirectionalColumn(
              children: [
                // Search and Filters
                DirectionalContainer(
                  color: DesignSystem.getSurfaceColor(context),
                  padding: ResponsiveUtils.responsivePadding(context),
                  child: DirectionalColumn(
                    children: [
                      // Search Bar
                      GBSearchBar(
                        hint: l10n.searchDonations,
                        onSearch: (query) {
                          setState(() {
                            _searchQuery = query;
                          });
                          _applyFilters();
                        },
                        onChanged: _onSearchChanged,
                        controller: _searchController,
                      ),

                      SizedBox(height: ResponsiveUtils.getSpacing(context)),

                      // Category Filters
                      GBFilterChips<String>(
                        options: _categoryOptions,
                        selectedValues: _selectedCategories,
                        onChanged: _onCategorySelected,
                        multiSelect: false,
                        scrollable: true,
                      ),
                    ],
                  ),
                ),

                // Donations List
                Expanded(
                  child: _isLoading && _donations.isEmpty
                      ? const GBDonationListSkeleton(itemCount: 4)
                      : _filteredDonations.isEmpty
                          ? _buildEmptyState()
                          : RefreshIndicator(
                              onRefresh: _loadDonations,
                              child: ResponsiveUtils.isMobile(context)
                                  ? _buildMobileList(user!)
                                  : _buildDesktopGrid(user!),
                            ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMobileList(User user) {
    return ListView.builder(
      padding: ResponsiveUtils.responsivePadding(context),
      itemCount: _filteredDonations.length,
      itemBuilder: (context, index) {
        final donation = _filteredDonations[index];
        return _buildMobileDonationCard(donation, user)
            .animate()
            .fadeIn(duration: 300.ms, delay: (index * 50).ms)
            .slideY(begin: 0.1, end: 0);
      },
    );
  }

  Widget _buildDesktopGrid(User user) {
    return ResponsiveGrid(
      children: _filteredDonations.map((donation) {
        return _buildDonationCard(donation, user);
      }).toList(),
      mobileColumns: 1,
      tabletColumns: 2,
      desktopColumns: 3,
      spacing: DesignSystem.spaceL,
    );
  }

  Widget _buildEmptyState() {
    return GBEmptyState(
      icon: Icons.volunteer_activism,
      title: 'No donations found',
      message: _searchQuery.isNotEmpty || _selectedCategory != 'all'
          ? 'Try adjusting your filters'
          : 'Be the first to make a donation!',
      actionLabel: 'Refresh',
      onAction: _loadDonations,
    );
  }

  Widget _buildMobileDonationCard(Donation donation, User user) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);

    return TouchCard(
      onTap: () => _showDonationDetails(donation),
      margin: EdgeInsets.only(bottom: ResponsiveUtils.getSpacing(context)),
      child: DirectionalColumn(
        crossAxisAlignment: localeProvider.isRTL
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          // Image (if available)
          if (donation.imageUrl != null && donation.imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(DesignSystem.radiusL),
                topRight: Radius.circular(DesignSystem.radiusL),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  donation.imageUrl!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      color: DesignSystem.neutral100,
                      child: Icon(
                        Icons.image_not_supported,
                        size: 48,
                        color: DesignSystem.textSecondary,
                      ),
                    );
                  },
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(DesignSystem.spaceL),
            child: DirectionalColumn(
              crossAxisAlignment: localeProvider.isRTL
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                // Category and Condition chips
                Wrap(
                  spacing: DesignSystem.spaceS,
                  runSpacing: DesignSystem.spaceS,
                  children: [
                    _buildChip(
                      donation.categoryDisplayName,
                      DesignSystem.primaryBlue,
                    ),
                    _buildChip(
                      donation.conditionDisplayName,
                      _getConditionColor(donation.condition),
                    ),
                  ],
                ),

                const SizedBox(height: DesignSystem.spaceM),

                // Title
                Text(
                  donation.title,
                  style: DesignSystem.titleMedium(context).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: DesignSystem.spaceS),

                // Description
                Text(
                  donation.description,
                  style: DesignSystem.bodyMedium(context).copyWith(
                    color: DesignSystem.textSecondary,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: DesignSystem.spaceM),

                // Donor and Location
                DirectionalRow(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 16,
                      color: DesignSystem.textSecondary,
                    ),
                    const SizedBox(width: DesignSystem.spaceXS),
                    Expanded(
                      child: Text(
                        donation.donorName,
                        style: DesignSystem.bodySmall(context),
                        overflow: TextOverflow.ellipsis,
                        textAlign: localeProvider.isRTL
                            ? TextAlign.right
                            : TextAlign.left,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: DesignSystem.spaceXS),

                DirectionalRow(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: DesignSystem.textSecondary,
                    ),
                    const SizedBox(width: DesignSystem.spaceXS),
                    Expanded(
                      child: Text(
                        donation.location,
                        style: DesignSystem.bodySmall(context),
                        overflow: TextOverflow.ellipsis,
                        textAlign: localeProvider.isRTL
                            ? TextAlign.right
                            : TextAlign.left,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: DesignSystem.spaceL),

                // Action Button (only for receivers)
                if (user.isReceiver)
                  TouchButton(
                    text: 'Request Donation',
                    onPressed: () => _requestDonation(donation),
                    size: TouchButtonSize.medium,
                    fullWidth: true,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonationCard(Donation donation, User user) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);

    return Container(
      margin: const EdgeInsets.only(bottom: DesignSystem.spaceL),
      child: WebCard(
        padding: EdgeInsets.zero,
        child: DirectionalColumn(
          crossAxisAlignment: localeProvider.isRTL
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            // Image (if available)
            if (donation.imageUrl != null && donation.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(DesignSystem.radiusL),
                  topRight: Radius.circular(DesignSystem.radiusL),
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
                      color: DesignSystem.neutral100,
                      child: Icon(
                        Icons.image_not_supported,
                        size: 48,
                        color: DesignSystem.textSecondary,
                      ),
                    );
                  },
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(DesignSystem.spaceL),
              child: DirectionalColumn(
                crossAxisAlignment: localeProvider.isRTL
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  // Category and Condition
                  DirectionalRow(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: DesignSystem.spaceM,
                          vertical: DesignSystem.spaceS,
                        ),
                        decoration: BoxDecoration(
                          color: DesignSystem.primaryBlue.withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(DesignSystem.radiusL),
                        ),
                        child: Text(
                          donation.categoryDisplayName,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: DesignSystem.primaryBlue,
                          ),
                        ),
                      ),
                      const SizedBox(width: DesignSystem.spaceM),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: DesignSystem.spaceM,
                          vertical: DesignSystem.spaceS,
                        ),
                        decoration: BoxDecoration(
                          color: _getConditionColor(donation.condition)
                              .withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(DesignSystem.radiusL),
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

                  const SizedBox(height: DesignSystem.spaceM),

                  // Title
                  Text(
                    donation.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: DesignSystem.textPrimary,
                    ),
                  ),

                  const SizedBox(height: DesignSystem.spaceM),

                  // Description
                  Text(
                    donation.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: DesignSystem.textSecondary,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: DesignSystem.spaceM),

                  // Donor and Location
                  DirectionalRow(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        size: 16,
                        color: DesignSystem.textSecondary,
                      ),
                      const SizedBox(width: DesignSystem.spaceS),
                      Text(
                        donation.donorName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: DesignSystem.textSecondary,
                        ),
                      ),
                      const SizedBox(width: DesignSystem.spaceL),
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: DesignSystem.textSecondary,
                      ),
                      const SizedBox(width: DesignSystem.spaceS),
                      Expanded(
                        child: Text(
                          donation.location,
                          style: const TextStyle(
                            fontSize: 12,
                            color: DesignSystem.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: DesignSystem.spaceL),

                  // Action Button (only for receivers)
                  if (user.isReceiver)
                    GBPrimaryButton(
                      text: 'Request Donation',
                      onPressed: () => _requestDonation(donation),
                      size: GBButtonSize.small,
                      fullWidth: true,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignSystem.spaceM,
        vertical: DesignSystem.spaceXS,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DesignSystem.radiusPill),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: DesignSystem.labelSmall(context).copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showDonationDetails(Donation donation) {
    // Navigate to donation details screen or show modal
    // For now, just show a simple dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(donation.title),
        content: Text(donation.description),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.close),
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
        return DesignSystem.error;
      default:
        return DesignSystem.textSecondary;
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
      title: Text(AppLocalizations.of(context)!.requestDonation),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You are requesting "${widget.donation.title}" from ${widget.donation.donorName}.',
              style: DesignSystem.bodyMedium(context),
            ),
            const SizedBox(height: DesignSystem.spaceM),
            TextField(
              controller: _messageController,
              maxLines: 3,
              maxLength: 500,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.messageOptional,
                hintText:
                    AppLocalizations.of(context)!.tellDonorWhyYouNeedDonation,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: DesignSystem.spaceS),
            Text(
              'The donor will see your contact information and can approve or decline your request.',
              style: DesignSystem.bodySmall(context).copyWith(
                color: DesignSystem.textSecondary,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        GBPrimaryButton(
          text: 'Send Request',
          onPressed: () {
            Navigator.pop(context, {
              'confirmed': true,
              'message': _messageController.text.trim().isEmpty
                  ? null
                  : _messageController.text.trim(),
            });
          },
          size: GBButtonSize.small,
        ),
      ],
    );
  }
}
