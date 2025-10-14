import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../widgets/app_button.dart';
import '../services/api_service.dart';
import '../models/donation.dart';
import 'create_donation_screen_enhanced.dart';

class MyDonationsScreen extends StatefulWidget {
  const MyDonationsScreen({Key? key}) : super(key: key);

  @override
  _MyDonationsScreenState createState() => _MyDonationsScreenState();
}

class _MyDonationsScreenState extends State<MyDonationsScreen> {
  List<Donation> _donations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDonations();
  }

  Future<void> _loadDonations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.getMyDonations();
      if (response.success && response.data != null) {
        setState(() {
          _donations = response.data!;
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

  Future<void> _createDonation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateDonationScreenEnhanced(),
      ),
    );

    if (result == true) {
      _loadDonations(); // Refresh the list
    }
  }

  Future<void> _editDonation(Donation donation) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateDonationScreenEnhanced(
            donation: donation), // Corrected this line
      ),
    );

    if (result == true) {
      _loadDonations(); // Refresh the list
    }
  }

  Future<void> _toggleAvailability(Donation donation) async {
    try {
      final response = await ApiService.updateDonation(
        id: donation.id.toString(),
        isAvailable: !donation.isAvailable,
      );

      if (response.success) {
        _showSuccessSnackbar(donation.isAvailable
            ? 'Donation marked as unavailable'
            : 'Donation marked as available');
        _loadDonations(); // Refresh the list
      } else {
        _showErrorSnackbar(response.error ?? 'Failed to update donation');
      }
    } catch (e) {
      _showErrorSnackbar('Network error: ${e.toString()}');
    }
  }

  Future<void> _deleteDonation(Donation donation) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Donation'),
        content: Text(
            'Are you sure you want to delete "${donation.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          AppButton(
            text: 'Delete',
            onPressed: () => Navigator.pop(context, true),
            variant: ButtonVariant.danger,
            size: ButtonSize.small,
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final response =
            await ApiService.deleteDonation(donation.id.toString());
        if (response.success) {
          _showSuccessSnackbar('Donation deleted successfully');
          _loadDonations(); // Refresh the list
        } else {
          _showErrorSnackbar(response.error ?? 'Failed to delete donation');
        }
      } catch (e) {
        _showErrorSnackbar('Network error: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'My Donations',
          style: TextStyle(
            color: AppTheme.textPrimaryColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppTheme.primaryColor),
            onPressed: _createDonation,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              ),
            )
          : _donations.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadDonations,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppTheme.spacingM),
                    itemCount: _donations.length,
                    itemBuilder: (context, index) {
                      final donation = _donations[index];
                      return _buildDonationCard(donation);
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createDonation,
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity( 0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(
              Icons.volunteer_activism,
              size: 50,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          const Text(
            'No Donations Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          const Text(
            'Start making a difference by\ncreating your first donation',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: AppTheme.spacingL),
          AppButton(
            text: 'Create First Donation',
            onPressed: _createDonation,
            size: ButtonSize.large,
          ),
        ],
      ),
    );
  }

  Widget _buildDonationCard(Donation donation) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        boxShadow: AppTheme.shadowMD,
        border: donation.isAvailable
            ? null
            : Border.all(color: Colors.grey.withOpacity( 0.5)),
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
              child: Stack(
                children: [
                  Image.network(
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
                  if (!donation.isAvailable)
                    Positioned(
                      top: AppTheme.spacingM,
                      right: AppTheme.spacingM,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingM,
                          vertical: AppTheme.spacingM,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(AppTheme.radiusL),
                        ),
                        child: const Text(
                          'Unavailable',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status and Category
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingM,
                        vertical: AppTheme.spacingM,
                      ),
                      decoration: BoxDecoration(
                        color: donation.isAvailable
                            ? Colors.green.withOpacity( 0.1)
                            : Colors.grey.withOpacity( 0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusL),
                      ),
                      child: Text(
                        donation.isAvailable ? 'Available' : 'Unavailable',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color:
                              donation.isAvailable ? Colors.green : Colors.grey,
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
                        color: AppTheme.primaryColor.withOpacity( 0.1),
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
                    const Spacer(),
                    // More options menu
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            _editDonation(donation);
                            break;
                          case 'toggle':
                            _toggleAvailability(donation);
                            break;
                          case 'delete':
                            _deleteDonation(donation);
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 16),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'toggle',
                          child: Row(
                            children: [
                              Icon(
                                donation.isAvailable
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(donation.isAvailable
                                  ? 'Mark Unavailable'
                                  : 'Mark Available'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 16, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete',
                                  style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                      child: const Icon(
                        Icons.more_vert,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppTheme.spacingM),

                // Title
                Text(
                  donation.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: donation.isAvailable
                        ? AppTheme.textPrimaryColor
                        : AppTheme.textSecondaryColor,
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

                // Location and Condition
                Row(
                  children: [
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
                    const SizedBox(width: AppTheme.spacingM),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingM,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getConditionColor(donation.condition)
                            .withOpacity( 0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusL),
                      ),
                      child: Text(
                        donation.conditionDisplayName,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: _getConditionColor(donation.condition),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppTheme.spacingM),

                // Quick Actions
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        text: 'Edit',
                        onPressed: () => _editDonation(donation),
                        variant: ButtonVariant.outline,
                        size: ButtonSize.small,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingM),
                    Expanded(
                      child: AppButton(
                        text: donation.isAvailable ? 'Hide' : 'Show',
                        onPressed: () => _toggleAvailability(donation),
                        variant: donation.isAvailable
                            ? ButtonVariant.secondary
                            : ButtonVariant.primary,
                        size: ButtonSize.small,
                      ),
                    ),
                  ],
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
