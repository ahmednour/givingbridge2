import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/design_system.dart';
import '../widgets/common/gb_button.dart';
import '../widgets/common/gb_filter_chips.dart';
import '../widgets/common/gb_empty_state.dart';
import '../widgets/common/web_card.dart';
import '../widgets/rtl/directional_row.dart';
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

  List<GBFilterOption<String>> _getFilters(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      GBFilterOption(value: 'all', label: l10n.all, icon: Icons.all_inbox),
      GBFilterOption(
          value: 'pending', label: l10n.pending, icon: Icons.pending),
      GBFilterOption(
          value: 'approved', label: l10n.approved, icon: Icons.check_circle),
      GBFilterOption(
          value: 'declined', label: l10n.declined, icon: Icons.cancel),
      GBFilterOption(
          value: 'completed', label: l10n.completed, icon: Icons.done_all),
    ];
  }

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.getIncomingRequests();
      if (!mounted) return;

      if (response.success && response.data != null) {
        setState(() {
          _requests = response.data!;
        });
      } else {
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          _showErrorSnackbar(response.error ?? l10n.failedToLoadRequests);
        }
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        _showErrorSnackbar('${l10n.networkError}: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<DonationRequest> get _filteredRequests {
    if (_selectedFilter == 'all') {
      return _requests;
    }
    return _requests.where((r) => r.status == _selectedFilter).toList();
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;

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
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: DesignSystem.spaceM),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: DesignSystem.success,
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
        builder: (dialogContext) => _ResponseDialog(
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
        builder: (dialogContext) => _ResponseDialog(
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
      backgroundColor: DesignSystem.getBackgroundColor(context),
      body: Column(
        children: [
          // Filter Chips
          Container(
            color: DesignSystem.getSurfaceColor(context),
            padding: const EdgeInsets.all(DesignSystem.spaceM),
            child: GBFilterChips<String>(
              options: _getFilters(context),
              selectedValues: [_selectedFilter],
              onChanged: (selected) {
                setState(() {
                  _selectedFilter = selected.first;
                });
              },
              multiSelect: false,
              scrollable: true,
            ),
          ),

          // Requests List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          DesignSystem.primaryBlue),
                    ),
                  )
                : filteredRequests.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadRequests,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(DesignSystem.spaceM),
                          itemCount: filteredRequests.length,
                          itemBuilder: (context, index) {
                            final request = filteredRequests[index];
                            return _buildRequestCard(request)
                                .animate(delay: (index * 50).ms)
                                .fadeIn(duration: 300.ms)
                                .slideY(begin: 0.1, end: 0);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;
    return GBEmptyState(
      icon: Icons.inbox,
      title: _selectedFilter == 'all'
          ? l10n.noIncomingRequests
          : 'No ${_selectedFilter} requests',
      message: _selectedFilter == 'all'
          ? l10n.whenReceiversRequest
          : 'Try adjusting your filter',
    );
  }

  Widget _buildRequestCard(DonationRequest request) {
    return Container(
      margin: const EdgeInsets.only(bottom: DesignSystem.spaceM),
      child: WebCard(
        padding: const EdgeInsets.all(DesignSystem.spaceM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status and Date
            DirectionalRow(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignSystem.spaceS,
                    vertical: DesignSystem.spaceXS,
                  ),
                  decoration: BoxDecoration(
                    color: request.statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(DesignSystem.radiusS),
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
                  style: TextStyle(
                    fontSize: 12,
                    color: DesignSystem.textSecondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: DesignSystem.spaceS),

            // Receiver Info
            DirectionalRow(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: DesignSystem.primaryBlue.withOpacity(0.1),
                  child: Text(
                    request.receiverName.isNotEmpty
                        ? request.receiverName[0].toUpperCase()
                        : 'R',
                    style: const TextStyle(
                      color: DesignSystem.primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: DesignSystem.spaceS),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.receiverName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        request.receiverEmail,
                        style: TextStyle(
                          fontSize: 12,
                          color: DesignSystem.textSecondary,
                        ),
                      ),
                      if (request.receiverPhone != null &&
                          request.receiverPhone!.isNotEmpty)
                        Text(
                          request.receiverPhone!,
                          style: TextStyle(
                            fontSize: 12,
                            color: DesignSystem.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: DesignSystem.spaceS),

            // Donation Info
            Container(
              padding: const EdgeInsets.all(DesignSystem.spaceS),
              decoration: BoxDecoration(
                color: DesignSystem.neutral50,
                borderRadius: BorderRadius.circular(DesignSystem.radiusS),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'رقم التبرع: ${request.donationId}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            if (request.message != null && request.message!.isNotEmpty) ...[
              const SizedBox(height: DesignSystem.spaceS),
              Text(
                'رسالة المستقبل:',
                style: TextStyle(
                  fontSize: 12,
                  color: DesignSystem.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: DesignSystem.spaceXS),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(DesignSystem.spaceS),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(DesignSystem.radiusS),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.2),
                  ),
                ),
                child: Text(
                  request.message!,
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ),
            ],

            if (request.responseMessage != null &&
                request.responseMessage!.isNotEmpty) ...[
              const SizedBox(height: DesignSystem.spaceS),
              Text(
                'ردك:',
                style: TextStyle(
                  fontSize: 12,
                  color: DesignSystem.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: DesignSystem.spaceXS),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(DesignSystem.spaceS),
                decoration: BoxDecoration(
                  color: DesignSystem.neutral50,
                  borderRadius: BorderRadius.circular(DesignSystem.radiusS),
                ),
                child: Text(
                  request.responseMessage!,
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ),
            ],

            const SizedBox(height: DesignSystem.spaceM),

            // Action Buttons
            if (request.isPending) ...[
              DirectionalRow(
                children: [
                  Expanded(
                    child: GBOutlineButton(
                      text: 'رسالة',
                      onPressed: () => _contactReceiver(request),
                      size: GBButtonSize.small,
                      leftIcon: const Icon(Icons.message_outlined, size: 16),
                    ),
                  ),
                  const SizedBox(width: DesignSystem.spaceS),
                  Expanded(
                    child: GBOutlineButton(
                      text: 'رفض',
                      onPressed: () => _respondToRequest(request, 'declined'),
                      size: GBButtonSize.small,
                    ),
                  ),
                  const SizedBox(width: DesignSystem.spaceS),
                  Expanded(
                    child: GBPrimaryButton(
                      text: 'قبول',
                      onPressed: () => _respondToRequest(request, 'approved'),
                      size: GBButtonSize.small,
                    ),
                  ),
                ],
              ),
            ] else if (request.isApproved) ...[
              DirectionalRow(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 20,
                  ),
                  const SizedBox(width: DesignSystem.spaceXS),
                  Expanded(
                    child: Text(
                      'تم القبول - في انتظار تأكيد المستقبل للاستلام',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  GBOutlineButton(
                    text: 'رسالة',
                    onPressed: () => _contactReceiver(request),
                    size: GBButtonSize.small,
                    leftIcon: const Icon(Icons.message_outlined, size: 16),
                  ),
                ],
              ),
            ] else if (request.isCompleted) ...[
              DirectionalRow(
                children: [
                  const Icon(
                    Icons.done_all,
                    color: Colors.blue,
                    size: 20,
                  ),
                  const SizedBox(width: DesignSystem.spaceXS),
                  Text(
                    'مكتمل - تم استلام التبرع بنجاح!',
                    style: TextStyle(
                      fontSize: 12,
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
      return 'منذ ${difference.inDays} يوم';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else {
      return 'الآن';
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
          variant: widget.action == AppLocalizations.of(context)!.decline
              ? GBButtonVariant.outline
              : GBButtonVariant.primary,
        ),
      ],
    );
  }
}
