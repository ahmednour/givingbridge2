import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../widgets/common/gb_button.dart';
import '../services/api_service.dart';
import '../l10n/app_localizations.dart';

class MyRequestsScreen extends StatefulWidget {
  const MyRequestsScreen({Key? key}) : super(key: key);

  @override
  _MyRequestsScreenState createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  List<DonationRequest> _requests = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';

  List<Map<String, dynamic>> _getFilters(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      {'value': 'all', 'label': l10n.all, 'icon': Icons.all_inbox},
      {'value': 'pending', 'label': l10n.pending, 'icon': Icons.pending},
      {'value': 'approved', 'label': l10n.approved, 'icon': Icons.check_circle},
      {'value': 'declined', 'label': l10n.declined, 'icon': Icons.cancel},
      {'value': 'completed', 'label': l10n.completed, 'icon': Icons.done_all},
    ];
  }

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
        final l10n = AppLocalizations.of(context)!;
        _showErrorSnackbar(response.error ?? l10n.failedToLoadRequests);
      }
    } catch (e) {
      final l10n = AppLocalizations.of(context)!;
      _showErrorSnackbar('${l10n.networkError}: ${e.toString()}');
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
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.cancelRequest),
        content: Text(l10n.cancelRequestConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.no),
          ),
          GBButton(
            text: l10n.yesCancelRequest,
            onPressed: () => Navigator.pop(context, true),
            variant: GBButtonVariant.danger,
            size: GBButtonSize.small,
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
          final l10n = AppLocalizations.of(context)!;
          _showSuccessSnackbar(l10n.requestCancelled);
          _loadRequests(); // Refresh the list
        } else {
          final l10n = AppLocalizations.of(context)!;
          _showErrorSnackbar(response.error ?? l10n.failedToCancelRequest);
        }
      } catch (e) {
        final l10n = AppLocalizations.of(context)!;
        _showErrorSnackbar('${l10n.networkError}: ${e.toString()}');
      }
    }
  }

  Future<void> _markAsCompleted(DonationRequest request) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.markAsCompleted),
        content: Text(l10n.haveReceivedDonation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.notYet),
          ),
          GBPrimaryButton(
            text: l10n.yes,
            onPressed: () => Navigator.pop(context, true),
            size: GBButtonSize.small,
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
          final l10n = AppLocalizations.of(context)!;
          _showSuccessSnackbar(l10n.requestMarkedCompleted);
          _loadRequests(); // Refresh the list
        } else {
          final l10n = AppLocalizations.of(context)!;
          _showErrorSnackbar(response.error ?? l10n.failedToCompleteRequest);
        }
      } catch (e) {
        final l10n = AppLocalizations.of(context)!;
        _showErrorSnackbar('${l10n.networkError}: ${e.toString()}');
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
        title: Text(
          AppLocalizations.of(context)!.myRequests,
          style: const TextStyle(
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
                itemCount: _getFilters(context).length,
                itemBuilder: (context, index) {
                  final filter = _getFilters(context)[index];
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
              color: AppTheme.primaryColor.withOpacity(0.1),
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
          GBOutlineButton(
            text: 'Browse Donations',
            onPressed: () => Navigator.pop(context),
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
                    color: request.statusColor.withOpacity(0.1),
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
                    child: GBOutlineButton(
                      text: 'Cancel Request',
                      onPressed: () => _cancelRequest(request),
                      size: GBButtonSize.small,
                    ),
                  ),
                ] else if (request.isApproved) ...[
                  Expanded(
                    child: GBPrimaryButton(
                      text: 'Mark as Received',
                      onPressed: () => _markAsCompleted(request),
                      size: GBButtonSize.small,
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
