import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../widgets/app_button.dart';
import '../services/api_service.dart';

class MyRequestsScreen extends StatefulWidget {
  const MyRequestsScreen({Key? key}) : super(key: key);

  @override
  _MyRequestsScreenState createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  List<DonationRequest> _requests = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';

  final List<Map<String, dynamic>> _filters = [
    {'value': 'all', 'label': 'All', 'icon': Icons.all_inbox},
    {'value': 'pending', 'label': 'Pending', 'icon': Icons.pending},
    {'value': 'approved', 'label': 'Approved', 'icon': Icons.check_circle},
    {'value': 'declined', 'label': 'Declined', 'icon': Icons.cancel},
    {'value': 'completed', 'label': 'Completed', 'icon': Icons.done_all},
  ];

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.getMyRequests();
      if (response.success && response.data != null) {
        setState(() {
          _requests = response.data!;
        });
      } else {
        _showErrorSnackbar(response.error ?? 'Failed to load requests');
      }
    } catch (e) {
      _showErrorSnackbar('Network error: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<DonationRequest> get _filteredRequests {
    if (_selectedFilter == 'all') {
      return _requests;
    }
    return _requests.where((r) => r.status == _selectedFilter).toList();
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

  Future<void> _cancelRequest(DonationRequest request) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Request'),
        content: const Text('Are you sure you want to cancel this request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          AppButton(
            text: 'Yes, Cancel',
            onPressed: () => Navigator.pop(context, true),
            variant: ButtonVariant.danger,
            size: ButtonSize.small,
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final response = await ApiService.updateRequestStatus(
          requestId: request.id.toString(),
          status: 'cancelled',
        );

        if (response.success) {
          _showSuccessSnackbar('Request cancelled successfully');
          _loadRequests(); // Refresh the list
        } else {
          _showErrorSnackbar(response.error ?? 'Failed to cancel request');
        }
      } catch (e) {
        _showErrorSnackbar('Network error: ${e.toString()}');
      }
    }
  }

  Future<void> _markAsCompleted(DonationRequest request) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Completed'),
        content: const Text('Have you received this donation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Not Yet'),
          ),
          AppButton(
            text: 'Yes, Received',
            onPressed: () => Navigator.pop(context, true),
            size: ButtonSize.small,
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final response = await ApiService.updateRequestStatus(
          requestId: request.id.toString(),
          status: 'completed',
        );

        if (response.success) {
          _showSuccessSnackbar('Request marked as completed!');
          _loadRequests(); // Refresh the list
        } else {
          _showErrorSnackbar(response.error ?? 'Failed to update request');
        }
      } catch (e) {
        _showErrorSnackbar('Network error: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredRequests = _filteredRequests;

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
          'My Requests',
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
          // Filter Tabs
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isSelected = _selectedFilter == filter['value'];

                  return Container(
                    margin: const EdgeInsets.only(right: AppTheme.spacingS),
                    child: FilterChip(
                      selected: isSelected,
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            filter['icon'],
                            size: 16,
                            color: isSelected
                                ? Colors.white
                                : AppTheme.textSecondaryColor,
                          ),
                          const SizedBox(width: AppTheme.spacingXS),
                          Text(filter['label']),
                        ],
                      ),
                      onSelected: (_) {
                        setState(() {
                          _selectedFilter = filter['value'];
                        });
                      },
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
          ),

          // Requests List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                    ),
                  )
                : filteredRequests.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadRequests,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(AppTheme.spacingM),
                          itemCount: filteredRequests.length,
                          itemBuilder: (context, index) {
                            final request = filteredRequests[index];
                            return _buildRequestCard(request);
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
              color: AppTheme.primaryColor.withOpacity( 0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.inbox,
              size: 40,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            _selectedFilter == 'all'
                ? 'No requests yet'
                : 'No ${_selectedFilter} requests',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: AppTheme.spacingXS),
          Text(
            _selectedFilter == 'all'
                ? 'Start browsing donations to make requests'
                : 'Try adjusting your filter or browse more donations',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          AppButton(
            text: 'Browse Donations',
            onPressed: () => Navigator.pop(context),
            variant: ButtonVariant.outline,
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(DonationRequest request) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        boxShadow: AppTheme.shadowMD,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status and Date
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingS,
                    vertical: AppTheme.spacingXS,
                  ),
                  decoration: BoxDecoration(
                    color: request.statusColor.withOpacity( 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusS),
                  ),
                  child: Text(
                    request.statusDisplayName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: request.statusColor,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(request.createdAt),
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spacingS),

            // Donation Info
            Text(
              'Requested from ${request.donorName}',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: AppTheme.spacingXS),
            Text(
              'Donation ID: ${request.donationId}',
              style: AppTheme.headingSmall,
            ),

            if (request.message != null && request.message!.isNotEmpty) ...[
              const SizedBox(height: AppTheme.spacingS),
              Text(
                'Your message:',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textSecondaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppTheme.spacingXS),
              Text(
                request.message!,
                style: AppTheme.bodyMedium,
              ),
            ],

            if (request.responseMessage != null &&
                request.responseMessage!.isNotEmpty) ...[
              const SizedBox(height: AppTheme.spacingS),
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingS),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(AppTheme.radiusS),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Donor\'s response:',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingXS),
                    Text(
                      request.responseMessage!,
                      style: AppTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: AppTheme.spacingM),

            // Action Buttons
            Row(
              children: [
                if (request.isPending) ...[
                  Expanded(
                    child: AppButton(
                      text: 'Cancel Request',
                      onPressed: () => _cancelRequest(request),
                      variant: ButtonVariant.outline,
                      size: ButtonSize.small,
                    ),
                  ),
                ] else if (request.isApproved) ...[
                  Expanded(
                    child: AppButton(
                      text: 'Mark as Received',
                      onPressed: () => _markAsCompleted(request),
                      size: ButtonSize.small,
                    ),
                  ),
                ] else ...[
                  const Expanded(
                    child: SizedBox(), // Empty space for alignment
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
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
