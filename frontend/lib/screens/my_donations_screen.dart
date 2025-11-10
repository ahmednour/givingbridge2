import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../core/theme/design_system.dart';
import '../widgets/common/gb_button.dart';
import '../widgets/common/gb_empty_state.dart';
import '../widgets/common/web_card.dart';
import '../widgets/rtl/directional_row.dart';
import '../widgets/rtl/directional_column.dart';
import '../widgets/rtl/directional_app_bar.dart';
import '../widgets/donations/approval_status_badge.dart';
import '../services/api_service.dart';
import '../providers/locale_provider.dart';
import '../models/donation.dart';
import 'create_donation_screen_enhanced.dart';
import '../l10n/app_localizations.dart';

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
        final l10n = AppLocalizations.of(context)!;
        _showSuccessSnackbar(donation.isAvailable
            ? (l10n.statusUnavailable)
            : (l10n.statusAvailable));
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
        title: Text(AppLocalizations.of(context)!.deleteDonation),
        content: Text(
            'Are you sure you want to delete "${donation.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          GBButton(
            text: 'Delete',
            onPressed: () => Navigator.pop(context, true),
            variant: GBButtonVariant.danger,
            size: GBButtonSize.small,
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
    final localeProvider = Provider.of<LocaleProvider>(context);
    final l10n = AppLocalizations.of(context)!;

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
            l10n.myDonations,
            style: const TextStyle(
              color: DesignSystem.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: localeProvider.isRTL,
          actions: [
            IconButton(
              icon: const Icon(Icons.add, color: DesignSystem.primaryBlue),
              onPressed: _createDonation,
            ),
          ],
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _donations.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: _loadDonations,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(DesignSystem.spaceL),
                      itemCount: _donations.length,
                      itemBuilder: (context, index) {
                        final donation = _donations[index];
                        return _buildDonationCard(donation)
                            .animate()
                            .fadeIn(duration: 300.ms, delay: (index * 50).ms)
                            .slideY(begin: 0.1, end: 0);
                      },
                    ),
                  ),
        floatingActionButton: FloatingActionButton(
          onPressed: _createDonation,
          backgroundColor: DesignSystem.primaryBlue,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return GBEmptyState(
      icon: Icons.volunteer_activism,
      title: 'No Donations Yet',
      message: 'Start making a difference by\ncreating your first donation',
      actionLabel: 'Create First Donation',
      onAction: _createDonation,
    );
  }

  Widget _buildDonationCard(Donation donation) {
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
                          color: DesignSystem.neutral100,
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 48,
                            color: DesignSystem.textSecondary,
                          ),
                        );
                      },
                    ),
                    if (!donation.isAvailable)
                      Positioned(
                        top: DesignSystem.spaceM,
                        right: DesignSystem.spaceM,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: DesignSystem.spaceM,
                            vertical: DesignSystem.spaceS,
                          ),
                          decoration: BoxDecoration(
                            color: DesignSystem.neutral600,
                            borderRadius:
                                BorderRadius.circular(DesignSystem.radiusL),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.statusUnavailable,
                            style: const TextStyle(
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
              padding: const EdgeInsets.all(DesignSystem.spaceL),
              child: DirectionalColumn(
                crossAxisAlignment: localeProvider.isRTL
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  // Status, Approval Status, and Category
                  DirectionalRow(
                    children: [
                      // Approval Status Badge
                      ApprovalStatusBadge(donation: donation),
                      const SizedBox(width: DesignSystem.spaceS),
                      // Availability Status
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: DesignSystem.spaceM,
                          vertical: DesignSystem.spaceS,
                        ),
                        decoration: BoxDecoration(
                          color: donation.isAvailable
                              ? DesignSystem.success.withOpacity(0.1)
                              : DesignSystem.neutral200,
                          borderRadius:
                              BorderRadius.circular(DesignSystem.radiusL),
                        ),
                        child: Text(
                          donation.isAvailable
                              ? (AppLocalizations.of(context)!.statusAvailable)
                              : (AppLocalizations.of(context)!
                                  .statusUnavailable),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: donation.isAvailable
                                ? DesignSystem.success
                                : DesignSystem.neutral600,
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
                            child: DirectionalRow(
                              children: [
                                const Icon(Icons.edit, size: 16),
                                const SizedBox(width: 8),
                                Text(AppLocalizations.of(context)!.edit),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'toggle',
                            child: DirectionalRow(
                              children: [
                                Icon(
                                  donation.isAvailable
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(donation.isAvailable
                                    ? (AppLocalizations.of(context)!
                                        .statusUnavailable)
                                    : (AppLocalizations.of(context)!
                                        .statusAvailable)),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: DirectionalRow(
                              children: [
                                const Icon(Icons.delete,
                                    size: 16, color: DesignSystem.error),
                                const SizedBox(width: 8),
                                Text(AppLocalizations.of(context)!.deleteAction,
                                    style: const TextStyle(
                                        color: DesignSystem.error)),
                              ],
                            ),
                          ),
                        ],
                        child: const Icon(
                          Icons.more_vert,
                          color: DesignSystem.textSecondary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: DesignSystem.spaceM),

                  // Title
                  Text(
                    donation.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: donation.isAvailable
                          ? DesignSystem.textPrimary
                          : DesignSystem.textSecondary,
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

                  // Rejection Reason (if rejected)
                  if (donation.isRejected &&
                      donation.rejectionReason != null) ...[
                    const SizedBox(height: DesignSystem.spaceM),
                    Container(
                      padding: const EdgeInsets.all(DesignSystem.spaceM),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius:
                            BorderRadius.circular(DesignSystem.radiusM),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: DirectionalRow(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline,
                              size: 16, color: Colors.red),
                          const SizedBox(width: DesignSystem.spaceS),
                          Expanded(
                            child: DirectionalColumn(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Rejection Reason:',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.red,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  donation.rejectionReason!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: DesignSystem.spaceM),

                  // Location and Condition
                  DirectionalRow(
                    children: [
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
                          textAlign: localeProvider.isRTL
                              ? TextAlign.right
                              : TextAlign.left,
                        ),
                      ),
                      const SizedBox(width: DesignSystem.spaceM),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: DesignSystem.spaceM,
                          vertical: 2,
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
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: _getConditionColor(donation.condition),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: DesignSystem.spaceL),

                  // Quick Actions
                  DirectionalRow(
                    children: [
                      Expanded(
                        child: GBOutlineButton(
                          text: 'Edit',
                          onPressed: () => _editDonation(donation),
                          size: GBButtonSize.small,
                        ),
                      ),
                      const SizedBox(width: DesignSystem.spaceM),
                      Expanded(
                        child: GBButton(
                          text: donation.isAvailable ? 'Hide' : 'Show',
                          onPressed: () => _toggleAvailability(donation),
                          variant: donation.isAvailable
                              ? GBButtonVariant.secondary
                              : GBButtonVariant.primary,
                          size: GBButtonSize.small,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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
