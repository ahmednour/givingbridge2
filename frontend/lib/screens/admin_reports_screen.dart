import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/design_system.dart';
import '../models/user_report.dart';
import '../services/api_service.dart';
import '../widgets/common/gb_button.dart';
import '../widgets/common/gb_empty_state.dart';
import '../widgets/common/gb_filter_chips.dart';
import '../widgets/common/gb_status_badge.dart';
import '../widgets/common/gb_user_avatar.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({Key? key}) : super(key: key);

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  List<UserReport> _reports = [];
  bool _isLoading = true;
  String? _errorMessage;
  List<String?> _selectedStatus = [];
  int _currentPage = 1;
  bool _hasMore = true;

  final List<GBFilterOption<String?>> _statusFilters = [
    GBFilterOption(label: 'All', value: null),
    GBFilterOption(label: 'Pending', value: 'pending'),
    GBFilterOption(label: 'Reviewed', value: 'reviewed'),
    GBFilterOption(label: 'Resolved', value: 'resolved'),
    GBFilterOption(label: 'Dismissed', value: 'dismissed'),
  ];

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _reports.clear();
      });
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await ApiService.getAllReports(
      status: _selectedStatus.isNotEmpty && _selectedStatus.first != null
          ? _selectedStatus.first
          : null,
      page: _currentPage,
      limit: 20,
    );

    if (!mounted) return;

    if (response.success && response.data != null) {
      setState(() {
        if (refresh) {
          _reports = response.data!.items;
        } else {
          _reports.addAll(response.data!.items);
        }
        _hasMore = response.data!.pagination.hasMore;
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = response.error;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreReports() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _currentPage++);
    await _loadReports();
  }

  void _onStatusFilterChanged(List<String?> statuses) {
    setState(() {
      _selectedStatus = statuses;
    });
    _loadReports(refresh: true);
  }

  Future<void> _showReportDetails(UserReport report) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => _ReportDetailDialog(report: report),
    );

    if (result == true) {
      // Refresh the list after status update
      _loadReports(refresh: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? DesignSystem.neutral900 : DesignSystem.neutral100,
      appBar: AppBar(
        backgroundColor: isDark ? DesignSystem.neutral900 : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? DesignSystem.neutral100 : DesignSystem.neutral900,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'User Reports',
          style: TextStyle(
            color: isDark ? DesignSystem.neutral100 : DesignSystem.neutral900,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: Icon(
                Icons.refresh,
                color:
                    isDark ? DesignSystem.neutral100 : DesignSystem.neutral900,
              ),
              onPressed: () => _loadReports(refresh: true),
              tooltip: 'Refresh',
            ),
        ],
      ),
      body: Column(
        children: [
          // Status filter
          Container(
            color: isDark ? DesignSystem.neutral900 : Colors.white,
            padding: const EdgeInsets.all(16),
            child: GBFilterChips<String?>(
              options: _statusFilters,
              selectedValues: _selectedStatus,
              onChanged: _onStatusFilterChanged,
              multiSelect: false,
            ),
          ),

          // Reports list
          Expanded(
            child: _buildBody(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_isLoading && _reports.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                DesignSystem.primaryBlue,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading reports...',
              style: TextStyle(
                color:
                    isDark ? DesignSystem.neutral400 : DesignSystem.neutral600,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null && _reports.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: DesignSystem.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load reports',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? DesignSystem.neutral100
                      : DesignSystem.neutral900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark
                      ? DesignSystem.neutral400
                      : DesignSystem.neutral600,
                ),
              ),
              const SizedBox(height: 24),
              GBButton(
                text: 'Try Again',
                variant: GBButtonVariant.primary,
                onPressed: () => _loadReports(refresh: true),
              ),
            ],
          ),
        ),
      );
    }

    if (_reports.isEmpty) {
      return GBEmptyState(
        icon: Icons.flag_outlined,
        title: 'No Reports',
        message: _selectedStatus.isNotEmpty && _selectedStatus.first != null
            ? 'No ${_selectedStatus.first} reports found.'
            : 'No user reports have been submitted yet.',
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadReports(refresh: true),
      color: DesignSystem.primaryBlue,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _reports.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _reports.length) {
            // Load more indicator
            _loadMoreReports();
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    DesignSystem.primaryBlue,
                  ),
                ),
              ),
            );
          }

          final report = _reports[index];
          return _ReportCard(
            report: report,
            isDark: isDark,
            onTap: () => _showReportDetails(report),
          )
              .animate()
              .fadeIn(
                duration: const Duration(milliseconds: 300),
                delay: Duration(milliseconds: 50 * (index % 10)),
              )
              .slideX(
                begin: 0.2,
                end: 0,
                duration: const Duration(milliseconds: 300),
                delay: Duration(milliseconds: 50 * (index % 10)),
              );
        },
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final UserReport report;
  final bool isDark;
  final VoidCallback onTap;

  const _ReportCard({
    Key? key,
    required this.report,
    required this.isDark,
    required this.onTap,
  }) : super(key: key);

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month${difference.inDays >= 60 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  IconData _getReasonIcon() {
    switch (report.reason) {
      case ReportReason.spam:
        return Icons.report;
      case ReportReason.harassment:
        return Icons.person_off;
      case ReportReason.inappropriateContent:
        return Icons.warning_amber;
      case ReportReason.scam:
        return Icons.gpp_bad;
      case ReportReason.fakeProfile:
        return Icons.person_remove;
      case ReportReason.other:
        return Icons.flag;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? DesignSystem.neutral800 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? DesignSystem.neutral700 : DesignSystem.neutral200,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                // Reason icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: DesignSystem.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getReasonIcon(),
                    color: DesignSystem.error,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),

                // Report info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.reason.displayName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? DesignSystem.neutral100
                              : DesignSystem.neutral900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(report.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? DesignSystem.neutral500
                              : DesignSystem.neutral600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Status badge
                _buildStatusBadge(report.status),
              ],
            ),

            const SizedBox(height: 12),

            // Reported user
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    isDark ? DesignSystem.neutral900 : DesignSystem.neutral100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  GBUserAvatar(
                    avatarUrl: report.reportedUser?.avatarUrl,
                    userName: report.reportedUser?.name ?? 'Unknown',
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Reported: ',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? DesignSystem.neutral500
                          : DesignSystem.neutral600,
                    ),
                  ),
                  Text(
                    report.reportedUser?.name ?? 'Unknown User',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? DesignSystem.neutral200
                          : DesignSystem.neutral900,
                    ),
                  ),
                  if (report.reportedUser?.role != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: DesignSystem.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        report.reportedUser!.role!.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: DesignSystem.primaryBlue,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Description preview
            Text(
              report.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                color:
                    isDark ? DesignSystem.neutral300 : DesignSystem.neutral700,
              ),
            ),

            // Tap to view more
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Tap to view details',
                  style: TextStyle(
                    fontSize: 12,
                    color: DesignSystem.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: DesignSystem.primaryBlue,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ReportStatus status) {
    switch (status) {
      case ReportStatus.pending:
        return GBStatusBadge.pending(size: GBStatusBadgeSize.small);
      case ReportStatus.reviewed:
        return GBStatusBadge.inProgress(size: GBStatusBadgeSize.small);
      case ReportStatus.resolved:
        return GBStatusBadge.completed(size: GBStatusBadgeSize.small);
      case ReportStatus.dismissed:
        return GBStatusBadge.cancelled(size: GBStatusBadgeSize.small);
    }
  }
}

class _ReportDetailDialog extends StatefulWidget {
  final UserReport report;

  const _ReportDetailDialog({
    Key? key,
    required this.report,
  }) : super(key: key);

  @override
  State<_ReportDetailDialog> createState() => _ReportDetailDialogState();
}

class _ReportDetailDialogState extends State<_ReportDetailDialog> {
  ReportStatus? _selectedStatus;
  final _reviewNotesController = TextEditingController();
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.report.status;
    _reviewNotesController.text = widget.report.reviewNotes ?? '';
  }

  @override
  void dispose() {
    _reviewNotesController.dispose();
    super.dispose();
  }

  Future<void> _updateReportStatus() async {
    if (_selectedStatus == null) return;

    setState(() => _isUpdating = true);

    final response = await ApiService.updateReportStatus(
      reportId: widget.report.id,
      status: _selectedStatus!.name,
      reviewNotes: _reviewNotesController.text.trim().isEmpty
          ? null
          : _reviewNotesController.text.trim(),
    );

    if (!mounted) return;

    setState(() => _isUpdating = false);

    if (response.success) {
      Navigator.of(context).pop(true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Report status updated successfully'),
          backgroundColor: DesignSystem.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.error ?? 'Failed to update report status'),
          backgroundColor: DesignSystem.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? DesignSystem.neutral900 : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: DesignSystem.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.flag,
                        color: DesignSystem.error,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Report Details',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? DesignSystem.neutral100
                                  : DesignSystem.neutral900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Report ID: #${widget.report.id}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? DesignSystem.neutral400
                                  : DesignSystem.neutral600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      icon: Icon(
                        Icons.close,
                        color: isDark
                            ? DesignSystem.neutral400
                            : DesignSystem.neutral600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Reporter info
                _buildInfoSection(
                  isDark: isDark,
                  title: 'Reported By',
                  icon: Icons.person_outline,
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.report.reporter?.name ?? 'Unknown',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? DesignSystem.neutral200
                              : DesignSystem.neutral900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.report.reporter?.email ?? '',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? DesignSystem.neutral400
                              : DesignSystem.neutral600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Reported user info
                _buildInfoSection(
                  isDark: isDark,
                  title: 'Reported User',
                  icon: Icons.person_off_outlined,
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.report.reportedUser?.name ?? 'Unknown',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? DesignSystem.neutral200
                                  : DesignSystem.neutral900,
                            ),
                          ),
                          if (widget.report.reportedUser?.role != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    DesignSystem.primaryBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                widget.report.reportedUser!.role!.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: DesignSystem.primaryBlue,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.report.reportedUser?.email ?? '',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? DesignSystem.neutral400
                              : DesignSystem.neutral600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Reason
                _buildInfoSection(
                  isDark: isDark,
                  title: 'Reason',
                  icon: Icons.category_outlined,
                  content: Text(
                    widget.report.reason.displayName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? DesignSystem.neutral200
                          : DesignSystem.neutral900,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Description
                _buildInfoSection(
                  isDark: isDark,
                  title: 'Description',
                  icon: Icons.description_outlined,
                  content: Text(
                    widget.report.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? DesignSystem.neutral300
                          : DesignSystem.neutral700,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Status selection
                Text(
                  'Update Status',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? DesignSystem.neutral200
                        : DesignSystem.neutral900,
                  ),
                ),
                const SizedBox(height: 12),

                ...ReportStatus.values.map((status) {
                  final isSelected = _selectedStatus == status;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: _isUpdating
                          ? null
                          : () => setState(() => _selectedStatus = status),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? DesignSystem.primaryBlue.withOpacity(0.1)
                              : (isDark
                                  ? DesignSystem.neutral800
                                  : DesignSystem.neutral100),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? DesignSystem.primaryBlue
                                : (isDark
                                    ? DesignSystem.neutral700
                                    : DesignSystem.neutral200),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                              color: isSelected
                                  ? DesignSystem.primaryBlue
                                  : (isDark
                                      ? DesignSystem.neutral500
                                      : DesignSystem.neutral400),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: status.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              status.displayName,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: isDark
                                    ? DesignSystem.neutral200
                                    : DesignSystem.neutral900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),

                const SizedBox(height: 24),

                // Review notes
                Text(
                  'Review Notes (Optional)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? DesignSystem.neutral200
                        : DesignSystem.neutral900,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _reviewNotesController,
                  enabled: !_isUpdating,
                  maxLines: 3,
                  maxLength: 500,
                  decoration: InputDecoration(
                    hintText: 'Add notes about your review decision...',
                    hintStyle: TextStyle(
                      color: isDark
                          ? DesignSystem.neutral500
                          : DesignSystem.neutral400,
                    ),
                    filled: true,
                    fillColor: isDark
                        ? DesignSystem.neutral800
                        : DesignSystem.neutral100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark
                            ? DesignSystem.neutral700
                            : DesignSystem.neutral300,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark
                            ? DesignSystem.neutral700
                            : DesignSystem.neutral300,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: DesignSystem.primaryBlue,
                        width: 2,
                      ),
                    ),
                  ),
                  style: TextStyle(
                    color: isDark
                        ? DesignSystem.neutral200
                        : DesignSystem.neutral900,
                  ),
                ),

                const SizedBox(height: 24),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: GBButton(
                        text: 'Cancel',
                        variant: GBButtonVariant.secondary,
                        onPressed: _isUpdating
                            ? null
                            : () => Navigator.of(context).pop(false),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GBButton(
                        text: 'Update Status',
                        variant: GBButtonVariant.primary,
                        isLoading: _isUpdating,
                        onPressed: _isUpdating ? null : _updateReportStatus,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection({
    required bool isDark,
    required String title,
    required IconData icon,
    required Widget content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? DesignSystem.neutral800 : DesignSystem.neutral100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color:
                    isDark ? DesignSystem.neutral500 : DesignSystem.neutral600,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? DesignSystem.neutral500
                      : DesignSystem.neutral600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          content,
        ],
      ),
    );
  }
}
