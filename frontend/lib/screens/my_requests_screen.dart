import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../core/theme/design_system.dart';
import '../widgets/common/gb_button.dart';
import '../widgets/common/gb_review_dialog.dart';
import '../widgets/common/gb_timeline.dart';
import '../widgets/common/gb_status_badge.dart';
import '../widgets/common/gb_filter_chips.dart';
import '../widgets/common/gb_empty_state.dart';
import '../widgets/rtl/directional_row.dart';
import '../widgets/rtl/directional_column.dart';
import '../widgets/rtl/directional_container.dart';
import '../widgets/rtl/directional_app_bar.dart';
import '../services/rtl_layout_service.dart';
import '../services/api_service.dart';
import '../providers/rating_provider.dart';
import '../providers/locale_provider.dart';
import '../l10n/app_localizations.dart';

// Import DonationRequest model from api_service.dart
export '../services/api_service.dart' show DonationRequest;

class MyRequestsScreen extends StatefulWidget {
  const MyRequestsScreen({Key? key}) : super(key: key);

  @override
  _MyRequestsScreenState createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  List<DonationRequest> _requests = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';
  String? _expandedRequestId;
  late RatingProvider _ratingProvider;

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
    _ratingProvider = Provider.of<RatingProvider>(context, listen: false);
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.getMyRequests();
      if (response.success && response.data != null) {
        // Check if each request has been rated
        final updatedRequests = <DonationRequest>[];
        for (final request in response.data!) {
          // Check if request has been rated
          await _ratingProvider.loadRequestRating(request.id);
          final isRated = _ratingProvider.getRequestRating(request.id) != null;

          updatedRequests.add(
            DonationRequest(
              id: request.id,
              donationId: request.donationId,
              donorId: request.donorId,
              donorName: request.donorName,
              receiverId: request.receiverId,
              receiverName: request.receiverName,
              receiverEmail: request.receiverEmail,
              receiverPhone: request.receiverPhone,
              message: request.message,
              status: request.status,
              responseMessage: request.responseMessage,
              createdAt: request.createdAt,
              updatedAt: request.updatedAt,
              respondedAt: request.respondedAt,
              isRated: isRated,
            ),
          );
        }

        setState(() {
          _requests = updatedRequests;
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

  Future<void> _rateDonor(DonationRequest request) async {
    final result = await GBReviewDialog.show(
      context: context,
      title: 'Rate Donor',
      subtitle: 'Share your experience with this donation',
      revieweeName: request.donorName,
      requireComment: true,
      minCommentLength: 10,
      maxCommentLength: 500,
      onSubmit: (rating, comment) async {
        // Submit rating using the rating provider
        await _ratingProvider.submitRating(
          requestId: request.id,
          rating: rating.toInt(),
          feedback: comment,
        );
      },
    );

    if (result == true && mounted) {
      _showSuccessSnackbar('Thank you for your feedback!');
      // Update the request to mark as rated
      setState(() {
        _requests = _requests
            .map((r) => r.id == request.id
                ? DonationRequest(
                    id: r.id,
                    donationId: r.donationId,
                    donorId: r.donorId,
                    donorName: r.donorName,
                    receiverId: r.receiverId,
                    receiverName: r.receiverName,
                    receiverEmail: r.receiverEmail,
                    receiverPhone: r.receiverPhone,
                    message: r.message,
                    status: r.status,
                    responseMessage: r.responseMessage,
                    createdAt: r.createdAt,
                    updatedAt: r.updatedAt,
                    respondedAt: r.respondedAt,
                    isRated: true,
                  )
                : r)
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredRequests = _filteredRequests;

    final localeProvider = Provider.of<LocaleProvider>(context);
    
    return Directionality(
      textDirection: localeProvider.textDirection,
      child: Scaffold(
        backgroundColor: DesignSystem.getBackgroundColor(context),
        appBar: DirectionalAppBar(
          backgroundColor: DesignSystem.getSurfaceColor(context),
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              localeProvider.getDirectionalIcon(
                start: Icons.arrow_back,
                end: Icons.arrow_forward,
              ),
              color: DesignSystem.textPrimary,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            AppLocalizations.of(context)!.myRequests,
            style: const TextStyle(
              color: DesignSystem.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: localeProvider.isRTL,
        ),
        body: DirectionalColumn(
          children: [
          // Filter Chips
          Container(
            color: DesignSystem.getSurfaceColor(context),
            padding: const EdgeInsets.all(DesignSystem.spaceL),
            child: GBFilterChips<String>(
              options: _getFilters(context),
              selectedValues: _selectedFilter == 'all' ? [] : [_selectedFilter],
              onChanged: (selected) {
                setState(() {
                  _selectedFilter = selected.isEmpty ? 'all' : selected.first;
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
                    child: CircularProgressIndicator(),
                  )
                : filteredRequests.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadRequests,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(DesignSystem.spaceL),
                          itemCount: filteredRequests.length,
                          itemBuilder: (context, index) {
                            final request = filteredRequests[index];
                            return _buildRequestCard(request)
                                .animate()
                                .fadeIn(
                                    duration: 300.ms, delay: (index * 50).ms)
                                .slideY(begin: 0.1, end: 0);
                          },
                        ),
                      ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;
    return GBEmptyState(
      icon: Icons.inbox_outlined,
      title: _selectedFilter == 'all'
          ? 'No requests yet'
          : 'No ${_selectedFilter} requests',
      message: _selectedFilter == 'all'
          ? 'Start browsing donations to make requests'
          : 'Try adjusting your filter or browse more donations',
      actionLabel: l10n.browseDonations,
      onAction: () => Navigator.pop(context),
    );
  }

  Widget _buildRequestCard(DonationRequest request) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    
    return Container(
      margin: const EdgeInsets.only(bottom: DesignSystem.spaceM),
      decoration: BoxDecoration(
        color: DesignSystem.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(DesignSystem.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.spaceM),
        child: DirectionalColumn(
          crossAxisAlignment: localeProvider.isRTL 
              ? CrossAxisAlignment.end 
              : CrossAxisAlignment.start,
          children: [
            // Status and Date
            DirectionalRow(
              children: [
                _buildStatusBadge(request),
                const Spacer(),
                Text(
                  _formatDate(request.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: DesignSystem.textSecondary,
                  ),
                ),
                const SizedBox(width: DesignSystem.spaceS),
                // Timeline toggle button
                InkWell(
                  onTap: () {
                    setState(() {
                      _expandedRequestId =
                          _expandedRequestId == request.id.toString()
                              ? null
                              : request.id.toString();
                    });
                  },
                  borderRadius: BorderRadius.circular(DesignSystem.radiusS),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(
                      _expandedRequestId == request.id.toString()
                          ? Icons.expand_less
                          : Icons.timeline,
                      size: 20,
                      color: DesignSystem.textSecondary,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: DesignSystem.spaceS),

            // Donation Info
            Text(
              'Requested from ${request.donorName}',
              style: const TextStyle(
                fontSize: 12,
                color: DesignSystem.textSecondary,
              ),
            ),
            const SizedBox(height: DesignSystem.spaceXS),
            Text(
              'Donation ID: ${request.donationId}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: DesignSystem.textPrimary,
              ),
            ),

            if (request.message != null && request.message!.isNotEmpty) ...[
              const SizedBox(height: DesignSystem.spaceS),
              const Text(
                'Your message:',
                style: TextStyle(
                  fontSize: 12,
                  color: DesignSystem.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: DesignSystem.spaceXS),
              Text(
                request.message!,
                style: const TextStyle(
                  fontSize: 14,
                  color: DesignSystem.textPrimary,
                ),
              ),
            ],

            if (request.responseMessage != null &&
                request.responseMessage!.isNotEmpty) ...[
              const SizedBox(height: DesignSystem.spaceS),
              Container(
                padding: const EdgeInsets.all(DesignSystem.spaceS),
                decoration: BoxDecoration(
                  color: DesignSystem.getBackgroundColor(context),
                  borderRadius: BorderRadius.circular(DesignSystem.radiusS),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Donor\'s response:',
                      style: TextStyle(
                        fontSize: 12,
                        color: DesignSystem.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: DesignSystem.spaceXS),
                    Text(
                      request.responseMessage!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: DesignSystem.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Timeline (expandable)
            if (_expandedRequestId == request.id.toString()) ...[
              const SizedBox(height: DesignSystem.spaceM),
              Container(
                padding: const EdgeInsets.all(DesignSystem.spaceM),
                decoration: BoxDecoration(
                  color: DesignSystem.getBackgroundColor(context),
                  borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                  border: Border.all(
                    color: DesignSystem.primaryBlue.withOpacity(0.1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const DirectionalRow(
                      children: [
                        Icon(
                          Icons.timeline,
                          size: 18,
                          color: DesignSystem.primaryBlue,
                        ),
                        SizedBox(width: DesignSystem.spaceXS),
                        Text(
                          'Request Timeline',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: DesignSystem.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: DesignSystem.spaceM),
                    GBTimeline(
                      events: _buildTimelineEvents(request),
                      showTime: true,
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: DesignSystem.spaceM),

            // Action Buttons
            DirectionalRow(
              children: [
                if (request.isPending) ...[
                  Expanded(
                    child: GBButton(
                      text: 'Cancel Request',
                      onPressed: () => _cancelRequest(request),
                      variant: GBButtonVariant.outline,
                      size: GBButtonSize.small,
                    ),
                  ),
                ] else if (request.isApproved) ...[
                  Expanded(
                    child: GBButton(
                      text: 'Mark as Received',
                      onPressed: () => _markAsCompleted(request),
                      variant: GBButtonVariant.primary,
                      size: GBButtonSize.small,
                    ),
                  ),
                ] else if (request.isCompleted) ...[
                  if (request.isRated) ...[
                    Expanded(
                      child: GBButton(
                        text: 'Rated',
                        onPressed: null,
                        variant: GBButtonVariant.outline,
                        size: GBButtonSize.small,
                      ),
                    ),
                  ] else ...[
                    Expanded(
                      child: GBButton(
                        text: 'Rate Donor',
                        leftIcon: const Icon(Icons.star,
                            size: 18, color: Colors.white),
                        onPressed: () => _rateDonor(request),
                        variant: GBButtonVariant.primary,
                        size: GBButtonSize.small,
                      ),
                    ),
                  ],
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

  Widget _buildStatusBadge(DonationRequest request) {
    if (request.isPending) {
      return GBStatusBadge.pending(size: GBStatusBadgeSize.small);
    } else if (request.status == 'approved') {
      return GBStatusBadge.approved(size: GBStatusBadgeSize.small);
    } else if (request.status == 'declined') {
      return GBStatusBadge.declined(size: GBStatusBadgeSize.small);
    } else if (request.status == 'in_progress') {
      return GBStatusBadge.inProgress(size: GBStatusBadgeSize.small);
    } else if (request.isCompleted) {
      return GBStatusBadge.completed(size: GBStatusBadgeSize.small);
    } else if (request.status == 'cancelled') {
      return GBStatusBadge.cancelled(size: GBStatusBadgeSize.small);
    } else {
      return GBStatusBadge(
        label: request.statusDisplayName,
        backgroundColor: request.statusColor.withOpacity(0.1),
        textColor: request.statusColor,
        size: GBStatusBadgeSize.small,
      );
    }
  }

  List<GBTimelineEvent> _buildTimelineEvents(DonationRequest request) {
    final events = <GBTimelineEvent>[];

    // 1. Request Created
    events.add(GBTimelineEvent.requestCreated(
      timestamp: DateTime.parse(request.createdAt),
      message: request.message,
    ));

    // 2. Response (if any)
    if (request.status == 'approved') {
      events.add(GBTimelineEvent.requestApproved(
        timestamp: DateTime.parse(request.updatedAt),
        donorMessage: request.responseMessage,
      ));

      // 3. In Progress (if applicable)
      if (request.isCompleted || request.status == 'in_progress') {
        events.add(GBTimelineEvent.donationInProgress(
          timestamp: DateTime.parse(request.updatedAt).add(Duration(days: 1)),
        ));
      }

      // 4. Completed (if applicable)
      if (request.isCompleted) {
        events.add(GBTimelineEvent.donationCompleted(
          timestamp: DateTime.parse(request.updatedAt),
        ));
      }
    } else if (request.status == 'declined') {
      events.add(GBTimelineEvent.requestDeclined(
        timestamp: DateTime.parse(request.updatedAt),
        reason: request.responseMessage,
      ));
    } else if (request.status == 'cancelled') {
      events.add(GBTimelineEvent.requestCancelled(
        timestamp: DateTime.parse(request.updatedAt),
      ));
    }

    return events;
  }
}
