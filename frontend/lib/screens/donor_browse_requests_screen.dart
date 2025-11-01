import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../core/theme/design_system.dart';
import '../widgets/common/gb_filter_chips.dart';
import '../widgets/common/gb_empty_state.dart';
import '../widgets/common/web_card.dart';
import '../widgets/rtl/directional_row.dart';
import '../widgets/rtl/directional_column.dart';
import '../widgets/rtl/directional_container.dart';
import '../widgets/rtl/directional_app_bar.dart';
import '../services/rtl_layout_service.dart';
import '../providers/locale_provider.dart';
import '../l10n/app_localizations.dart';
import '../services/api_service.dart';
import 'chat_screen_enhanced.dart';

class DonorBrowseRequestsScreen extends StatefulWidget {
  const DonorBrowseRequestsScreen({Key? key}) : super(key: key);

  @override
  State<DonorBrowseRequestsScreen> createState() =>
      _DonorBrowseRequestsScreenState();
}

class _DonorBrowseRequestsScreenState extends State<DonorBrowseRequestsScreen> {
  bool _isLoading = true;
  List<dynamic> _requests = [];
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiService.getIncomingRequests();
      if (response.success && mounted) {
        setState(() {
          _requests = response.data ?? [];
        });
      }
    } catch (e) {
      print('Error loading requests: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: DirectionalRow(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: DesignSystem.spaceM),
                Expanded(
                  child:
                      Text(AppLocalizations.of(context)!.failedToLoadRequests),
                ),
              ],
            ),
            backgroundColor: DesignSystem.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<GBFilterOption<String>> _getFilters(AppLocalizations l10n) {
    return [
      GBFilterOption(value: 'all', label: l10n.all),
      GBFilterOption(value: 'pending', label: l10n.pending),
      GBFilterOption(value: 'approved', label: l10n.approved),
      GBFilterOption(value: 'declined', label: l10n.declined),
      GBFilterOption(value: 'completed', label: l10n.completed),
    ];
  }

  List<dynamic> get _filteredRequests {
    if (_selectedFilter == 'all') return _requests;
    return _requests.where((r) => r.status == _selectedFilter).toList();
  }

  Future<void> _approveRequest(dynamic request) async {
    try {
      final response = await ApiService.approveRequest(request.id);
      if (response.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: DirectionalRow(
                children: [
                  const Icon(Icons.check_circle_outline, color: Colors.white),
                  const SizedBox(width: DesignSystem.spaceM),
                  Expanded(
                    child: Text(AppLocalizations.of(context)!.requestApproved),
                  ),
                ],
              ),
              backgroundColor: DesignSystem.success,
            ),
          );
          _loadRequests();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: DesignSystem.spaceM),
                Expanded(
                  child:
                      Text(AppLocalizations.of(context)!.failedToUpdateRequest),
                ),
              ],
            ),
            backgroundColor: DesignSystem.error,
          ),
        );
      }
    }
  }

  Future<void> _declineRequest(dynamic request) async {
    try {
      final response = await ApiService.declineRequest(request.id);
      if (response.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_outline, color: Colors.white),
                  const SizedBox(width: DesignSystem.spaceM),
                  Expanded(
                    child: Text(AppLocalizations.of(context)!.requestDeclined),
                  ),
                ],
              ),
              backgroundColor: DesignSystem.error,
            ),
          );
          _loadRequests();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: DesignSystem.spaceM),
                Expanded(
                  child:
                      Text(AppLocalizations.of(context)!.failedToUpdateRequest),
                ),
              ],
            ),
            backgroundColor: DesignSystem.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleProvider>(context);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 768;

    return Directionality(
      textDirection: localeProvider.textDirection,
      child: Scaffold(
        appBar: DirectionalAppBar(
          title: Text(l10n.incomingRequests),
          backgroundColor: DesignSystem.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: localeProvider.isRTL,
        ),
        backgroundColor: DesignSystem.getBackgroundColor(context),
        body: DirectionalColumn(
          children: [
          // Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: DesignSystem.getSurfaceColor(context),
            child: GBFilterChips<String>(
              options: _getFilters(l10n),
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

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredRequests.isEmpty
                    ? _buildEmptyState(l10n)
                    : RefreshIndicator(
                        onRefresh: _loadRequests,
                        child: ListView.builder(
                          padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
                          itemCount: _filteredRequests.length,
                          itemBuilder: (context, index) {
                            return _buildRequestCard(
                              _filteredRequests[index],
                              l10n,
                              isDesktop,
                            )
                                .animate(delay: (index * 50).ms)
                                .fadeIn(duration: 300.ms)
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

  Widget _buildEmptyState(AppLocalizations l10n) {
    return GBEmptyState(
      icon: Icons.inbox_outlined,
      title: l10n.noIncomingRequests,
      message: l10n.whenReceiversRequest,
    );
  }

  Widget _buildRequestCard(
    dynamic request,
    AppLocalizations l10n,
    bool isDesktop,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: WebCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${l10n.requestFrom} ${request.receiverName}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: DesignSystem.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Donation #${request.donationId}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: DesignSystem.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(request.status, l10n),
              ],
            ),

            const SizedBox(height: 16),

            // Message
            if (request.message != null && request.message!.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: DesignSystem.neutral50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  request.message!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: DesignSystem.textPrimary,
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Date
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: DesignSystem.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  '${l10n.requestedOn} ${request.createdAt}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: DesignSystem.textSecondary,
                  ),
                ),
              ],
            ),

            // Actions
            if (request.status == 'pending') ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _declineRequest(request),
                      icon: const Icon(Icons.close, size: 20),
                      label: Text(l10n.declineRequest),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: DesignSystem.error,
                        side: const BorderSide(color: DesignSystem.error),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _approveRequest(request),
                      icon: const Icon(Icons.check, size: 20),
                      label: Text(l10n.approveRequest),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DesignSystem.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // Contact button for approved requests
            if (request.status == 'approved') ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreenEnhanced(
                          otherUserId: request.receiverId,
                          otherUserName: request.receiverName,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.chat, size: 20),
                  label: Text(l10n.contactRequester),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignSystem.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, AppLocalizations l10n) {
    Color color;
    String label;

    switch (status) {
      case 'pending':
        color = DesignSystem.warning;
        label = l10n.pending;
        break;
      case 'approved':
        color = DesignSystem.success;
        label = l10n.approved;
        break;
      case 'declined':
        color = DesignSystem.error;
        label = l10n.declined;
        break;
      case 'completed':
        color = const Color(0xFF8B5CF6);
        label = l10n.completed;
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
