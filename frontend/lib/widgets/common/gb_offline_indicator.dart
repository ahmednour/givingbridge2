import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/design_system.dart';
import '../../services/network_status_service.dart';
import '../../services/offline_service.dart';
import 'gb_button.dart';

/// Comprehensive offline mode indicator with status information
class GBOfflineIndicator extends StatelessWidget {
  final bool showDetails;

  const GBOfflineIndicator({
    Key? key,
    this.showDetails = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<NetworkStatusService>(
      builder: (context, networkStatus, child) {
        if (networkStatus.isOnline) {
          return const SizedBox.shrink();
        }

        final offlineService = OfflineService();
        final status = offlineService.getStatus();
        final pendingCount = status['pendingOperations'] as int;

        return Container(
          margin: const EdgeInsets.all(DesignSystem.spaceM),
          padding: const EdgeInsets.all(DesignSystem.spaceL),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                DesignSystem.warning,
                DesignSystem.warning.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(DesignSystem.radiusM),
            boxShadow: [
              BoxShadow(
                color: DesignSystem.warning.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(DesignSystem.spaceM),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(DesignSystem.radiusS),
                    ),
                    child: const Icon(
                      Icons.cloud_off_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: DesignSystem.spaceM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Offline Mode',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'You are currently offline',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (showDetails && pendingCount > 0) ...[
                const SizedBox(height: DesignSystem.spaceM),
                Container(
                  padding: const EdgeInsets.all(DesignSystem.spaceM),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(DesignSystem.radiusS),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.sync,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: DesignSystem.spaceM),
                      Expanded(
                        child: Text(
                          pendingCount == 1
                              ? '1 change will sync when you\'re back online'
                              : '$pendingCount changes will sync when you\'re back online',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.95),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// Compact offline status badge
class GBOfflineBadge extends StatelessWidget {
  const GBOfflineBadge({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<NetworkStatusService>(
      builder: (context, networkStatus, child) {
        if (networkStatus.isOnline) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DesignSystem.spaceM,
            vertical: DesignSystem.spaceS,
          ),
          decoration: BoxDecoration(
            color: DesignSystem.warning,
            borderRadius: BorderRadius.circular(DesignSystem.radiusL),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.wifi_off,
                color: Colors.white,
                size: 14,
              ),
              SizedBox(width: 6),
              Text(
                'Offline',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Offline mode bottom sheet with detailed status
class GBOfflineStatusSheet extends StatelessWidget {
  const GBOfflineStatusSheet({Key? key}) : super(key: key);

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const GBOfflineStatusSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final offlineService = OfflineService();
    final status = offlineService.getStatus();
    final pendingOps = status['operations'] as List<dynamic>;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      decoration: BoxDecoration(
        color: DesignSystem.getSurfaceColor(context),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(DesignSystem.radiusXL),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: DesignSystem.spaceM),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: DesignSystem.neutral400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(DesignSystem.spaceL),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(DesignSystem.spaceM),
                  decoration: BoxDecoration(
                    color: DesignSystem.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                  ),
                  child: Icon(
                    Icons.cloud_off_rounded,
                    color: DesignSystem.warning,
                    size: 28,
                  ),
                ),
                const SizedBox(width: DesignSystem.spaceM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Offline Status',
                        style: DesignSystem.displaySmall(context).copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Changes will sync when online',
                        style: DesignSystem.bodyMedium(context).copyWith(
                          color: DesignSystem.neutral600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Pending operations list
          if (pendingOps.isEmpty)
            Padding(
              padding: const EdgeInsets.all(DesignSystem.spaceXXL),
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: DesignSystem.success,
                  ),
                  const SizedBox(height: DesignSystem.spaceM),
                  Text(
                    'All Changes Synced',
                    style: DesignSystem.bodyLarge(context).copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: DesignSystem.spaceS),
                  Text(
                    'No pending operations',
                    style: DesignSystem.bodyMedium(context).copyWith(
                      color: DesignSystem.neutral600,
                    ),
                  ),
                ],
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                padding: const EdgeInsets.all(DesignSystem.spaceL),
                shrinkWrap: true,
                itemCount: pendingOps.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: DesignSystem.spaceM),
                itemBuilder: (context, index) {
                  final op = pendingOps[index];
                  return _buildOperationCard(context, op);
                },
              ),
            ),

          // Sync button
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(DesignSystem.spaceL),
              child: Consumer<NetworkStatusService>(
                builder: (context, networkStatus, child) {
                  return GBButton(
                    text: networkStatus.isOnline
                        ? 'Sync Now'
                        : 'Waiting for connection...',
                    variant: GBButtonVariant.primary,
                    fullWidth: true,
                    onPressed: networkStatus.isOnline
                        ? () async {
                            await offlineService.forceSync();
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Sync completed!'),
                                  backgroundColor: DesignSystem.success,
                                ),
                              );
                            }
                          }
                        : null,
                    leftIcon: Icon(
                      networkStatus.isOnline ? Icons.sync : Icons.wifi_off,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOperationCard(BuildContext context, Map<String, dynamic> op) {
    final type = op['type'] as String;
    final timestamp = DateTime.parse(op['timestamp']);
    final retryCount = op['retryCount'] as int;
    final error = op['error'] as String?;

    IconData icon;
    Color color;

    switch (type) {
      case 'createDonation':
      case 'updateDonation':
        icon = Icons.volunteer_activism;
        color = DesignSystem.accentPink;
        break;
      case 'createRequest':
      case 'updateRequest':
        icon = Icons.request_page;
        color = DesignSystem.accentPurple;
        break;
      case 'sendMessage':
        icon = Icons.message;
        color = DesignSystem.primaryBlue;
        break;
      default:
        icon = Icons.edit;
        color = DesignSystem.neutral600;
    }

    return Container(
      padding: const EdgeInsets.all(DesignSystem.spaceM),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(DesignSystem.radiusM),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(DesignSystem.spaceS),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(DesignSystem.radiusS),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: DesignSystem.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatOperationType(type),
                  style: DesignSystem.bodyMedium(context).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTimestamp(timestamp),
                  style: DesignSystem.bodySmall(context).copyWith(
                    color: DesignSystem.neutral600,
                  ),
                ),
                if (error != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Failed: $error',
                    style: DesignSystem.bodySmall(context).copyWith(
                      color: DesignSystem.error,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (retryCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: DesignSystem.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(DesignSystem.radiusS),
              ),
              child: Text(
                'Retry $retryCount',
                style: TextStyle(
                  color: DesignSystem.warning,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatOperationType(String type) {
    return type
        .replaceAllMapped(
          RegExp(r'([A-Z])'),
          (match) => ' ${match.group(0)}',
        )
        .trim()
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }
}
