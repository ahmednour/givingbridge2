import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../widgets/common/gb_button.dart';
import '../services/api_service.dart';
import 'chat_screen_enhanced.dart';
import '../l10n/app_localizations.dart';

class IncomingRequestsScreen extends StatefulWidget {
  const IncomingRequestsScreen({Key? key}) : super(key: key);

  @override
  _IncomingRequestsScreenState createState() => _IncomingRequestsScreenState();
}

class _IncomingRequestsScreenState extends State<IncomingRequestsScreen> {
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
      final response = await ApiService.getIncomingRequests();
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

  Future<void> _respondToRequest(DonationRequest request, String action) async {
    final l10n = AppLocalizations.of(context)!;
    String? responseMessage;

    if (action == 'declined') {
      // Ask for decline reason
      final result = await showDialog<String?>(
        context: context,
        builder: (context) => _ResponseDialog(
          title: l10n.declineRequest,
          hint: l10n.provideDeclineReason,
          action: l10n.decline,
        ),
      );

      if (result == null) return; // User cancelled
      responseMessage = result;
    } else if (action == 'approved') {
      // Ask for approval message
      final result = await showDialog<String?>(
        context: context,
        builder: (context) => _ResponseDialog(
          title: l10n.approveRequest,
          hint: l10n.provideApprovalMessage,
          action: l10n.approve,
        ),
      );

      if (result == null) return; // User cancelled
      responseMessage = result;
    }

    try {
      final response = await ApiService.updateRequestStatus(
        requestId: request.id.toString(),
        status: action,
        responseMessage: responseMessage,
      );

      if (response.success) {
        _showSuccessSnackbar(l10n.requestUpdatedSuccess);
        _loadRequests(); // Refresh the list
      } else {
        _showErrorSnackbar(response.error ?? l10n.failedToUpdateRequest);
      }
    } catch (e) {
      _showErrorSnackbar('${l10n.networkError}: ${e.toString()}');
    }
  }

  void _contactReceiver(DonationRequest request) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreenEnhanced(
          otherUserId: request.receiverId.toString(),
          otherUserName: request.receiverName,
          donationId: request.donationId.toString(),
          requestId: request.id.toString(),
        ),
      ),
    );
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
          'Incoming Requests',
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
                ? 'When people request your donations, they\'ll appear here'
                : 'Try adjusting your filter',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
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

            // Receiver Info
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  child: Text(
                    request.receiverName.isNotEmpty
                        ? request.receiverName[0].toUpperCase()
                        : 'R',
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingS),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.receiverName,
                        style: AppTheme.headingSmall.copyWith(fontSize: 16),
                      ),
                      Text(
                        request.receiverEmail,
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                      if (request.receiverPhone != null &&
                          request.receiverPhone!.isNotEmpty)
                        Text(
                          request.receiverPhone!,
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spacingS),

            // Donation Info
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
                    'Donation ID: ${request.donationId}',
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            if (request.message != null && request.message!.isNotEmpty) ...[
              const SizedBox(height: AppTheme.spacingS),
              Text(
                'Receiver\'s message:',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textSecondaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppTheme.spacingXS),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppTheme.spacingS),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(AppTheme.radiusS),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.2),
                  ),
                ),
                child: Text(
                  request.message!,
                  style: AppTheme.bodyMedium,
                ),
              ),
            ],

            if (request.responseMessage != null &&
                request.responseMessage!.isNotEmpty) ...[
              const SizedBox(height: AppTheme.spacingS),
              Text(
                'Your response:',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textSecondaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppTheme.spacingXS),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppTheme.spacingS),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(AppTheme.radiusS),
                ),
                child: Text(
                  request.responseMessage!,
                  style: AppTheme.bodyMedium,
                ),
              ),
            ],

            const SizedBox(height: AppTheme.spacingM),

            // Action Buttons
            if (request.isPending) ...[
              Row(
                children: [
                  Expanded(
                    child: GBOutlineButton(
                      text: 'Message',
                      onPressed: () => _contactReceiver(request),
                      size: GBButtonSize.small,
                      leftIcon: const Icon(Icons.message_outlined, size: 16),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingS),
                  Expanded(
                    child: GBOutlineButton(
                      text: 'Decline',
                      onPressed: () => _respondToRequest(request, 'declined'),
                      size: GBButtonSize.small,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingS),
                  Expanded(
                    child: GBPrimaryButton(
                      text: 'Approve',
                      onPressed: () => _respondToRequest(request, 'approved'),
                      size: GBButtonSize.small,
                    ),
                  ),
                ],
              ),
            ] else if (request.isApproved) ...[
              Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 20,
                  ),
                  const SizedBox(width: AppTheme.spacingXS),
                  Expanded(
                    child: Text(
                      'Approved - Waiting for receiver to confirm receipt',
                      style: AppTheme.bodySmall.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  GBOutlineButton(
                    text: 'Message',
                    onPressed: () => _contactReceiver(request),
                    size: GBButtonSize.small,
                    leftIcon: const Icon(Icons.message_outlined, size: 16),
                  ),
                ],
              ),
            ] else if (request.isCompleted) ...[
              Row(
                children: [
                  const Icon(
                    Icons.done_all,
                    color: Colors.blue,
                    size: 20,
                  ),
                  const SizedBox(width: AppTheme.spacingXS),
                  Text(
                    'Completed - Donation successfully received!',
                    style: AppTheme.bodySmall.copyWith(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
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

class _ResponseDialog extends StatefulWidget {
  final String title;
  final String hint;
  final String action;

  const _ResponseDialog({
    Key? key,
    required this.title,
    required this.hint,
    required this.action,
  }) : super(key: key);

  @override
  _ResponseDialogState createState() => _ResponseDialogState();
}

class _ResponseDialogState extends State<_ResponseDialog> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _messageController,
              maxLines: 3,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: widget.hint,
                border: const OutlineInputBorder(),
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
        GBButton(
          text: widget.action,
          onPressed: () {
            Navigator.pop(
                context,
                _messageController.text.trim().isEmpty
                    ? null
                    : _messageController.text.trim());
          },
          size: GBButtonSize.small,
          variant: widget.action == 'Decline'
              ? GBButtonVariant.outline
              : GBButtonVariant.primary,
        ),
      ],
    );
  }
}
