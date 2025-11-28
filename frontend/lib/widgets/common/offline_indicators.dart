import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/design_system.dart';
import '../../core/utils/responsive_utils.dart';
import '../../services/offline_service.dart';
import '../../services/network_status_service.dart';
import '../../l10n/app_localizations.dart';

/// Offline status banner that appears at the top of the screen
class OfflineBanner extends StatelessWidget {
  final bool showWhenOnline;

  const OfflineBanner({
    Key? key,
    this.showWhenOnline = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<NetworkStatusService>(
      builder: (context, networkService, child) {
        final isOnline = networkService.isOnline;
        final offlineService = OfflineService();
        final pendingCount = offlineService.pendingOperationsCount;

        if (isOnline && !showWhenOnline && pendingCount == 0) {
          return const SizedBox.shrink();
        }

        return AnimatedContainer(
          duration: DesignSystem.shortDuration,
          height: isOnline ? (pendingCount > 0 ? 40 : 0) : 40,
          child: Container(
            width: double.infinity,
            color: isOnline
                ? (pendingCount > 0
                    ? DesignSystem.warning
                    : DesignSystem.success)
                : DesignSystem.error,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: ResponsiveUtils.responsiveHorizontalPadding(context),
                child: Row(
                  children: [
                    Icon(
                      isOnline
                          ? (pendingCount > 0 ? Icons.sync : Icons.wifi)
                          : Icons.wifi_off,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: DesignSystem.spaceS),
                    Expanded(
                      child: Text(
                        _getBannerText(context, isOnline, pendingCount),
                        style: DesignSystem.bodySmall(context).copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (pendingCount > 0 && isOnline)
                      TextButton(
                        onPressed: () => _showSyncDialog(context),
                        child: Text(
                          'Sync',
                          style: DesignSystem.labelSmall(context).copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _getBannerText(BuildContext context, bool isOnline, int pendingCount) {
    final l10n = AppLocalizations.of(context)!;

    if (!isOnline) {
      return l10n.offlineMode;
    } else if (pendingCount > 0) {
      return 'Syncing $pendingCount pending changes...';
    } else {
      return 'Back online';
    }
  }

  void _showSyncDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const OfflineSyncDialog(),
    );
  }
}

/// Floating offline indicator
class OfflineFloatingIndicator extends StatelessWidget {
  const OfflineFloatingIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<NetworkStatusService>(
      builder: (context, networkService, child) {
        if (networkService.isOnline) {
          return const SizedBox.shrink();
        }

        return Positioned(
          top: MediaQuery.of(context).padding.top + 60,
          right: DesignSystem.spaceM,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(DesignSystem.radiusPill),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DesignSystem.spaceM,
                vertical: DesignSystem.spaceS,
              ),
              decoration: BoxDecoration(
                color: DesignSystem.error,
                borderRadius: BorderRadius.circular(DesignSystem.radiusPill),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.wifi_off,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: DesignSystem.spaceS),
                  Text(
                    'Offline',
                    style: DesignSystem.labelSmall(context).copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Offline sync dialog
class OfflineSyncDialog extends StatefulWidget {
  const OfflineSyncDialog({Key? key}) : super(key: key);

  @override
  State<OfflineSyncDialog> createState() => _OfflineSyncDialogState();
}

class _OfflineSyncDialogState extends State<OfflineSyncDialog> {
  final OfflineService _offlineService = OfflineService();
  bool _isSyncing = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final status = _offlineService.getStatus();
    final operations = status['operations'] as List<dynamic>;

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.sync, color: DesignSystem.primaryBlue),
          const SizedBox(width: DesignSystem.spaceM),
          Text(l10n.syncPendingChanges),
        ],
      ),
      content: SizedBox(
        width: ResponsiveUtils.isMobile(context) ? double.maxFinite : 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${operations.length} pending operations',
              style: DesignSystem.bodyMedium(context).copyWith(
                color: DesignSystem.textSecondary,
              ),
            ),
            const SizedBox(height: DesignSystem.spaceL),
            if (operations.isNotEmpty) ...[
              Text(
                'Pending Operations:',
                style: DesignSystem.labelLarge(context).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: DesignSystem.spaceM),
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: operations.length,
                  itemBuilder: (context, index) {
                    final operation = operations[index];
                    return _buildOperationTile(operation);
                  },
                ),
              ),
            ],
            if (_isSyncing) ...[
              const SizedBox(height: DesignSystem.spaceL),
              Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: DesignSystem.spaceM),
                  Text(
                    'Syncing...',
                    style: DesignSystem.bodyMedium(context),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSyncing ? null : () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: _isSyncing ? null : _syncNow,
          child: Text(l10n.syncNow),
        ),
      ],
    );
  }

  Widget _buildOperationTile(Map<String, dynamic> operation) {
    final type = operation['type'] as String;
    final timestamp = DateTime.parse(operation['timestamp']);
    final retryCount = operation['retryCount'] as int;
    final error = operation['error'] as String?;

    return ListTile(
      dense: true,
      leading: Icon(
        _getOperationIcon(type),
        size: 20,
        color: error != null ? DesignSystem.error : DesignSystem.textSecondary,
      ),
      title: Text(
        _getOperationTitle(type),
        style: DesignSystem.bodyMedium(context),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatTimestamp(timestamp),
            style: DesignSystem.bodySmall(context),
          ),
          if (retryCount > 0)
            Text(
              'Retried $retryCount times',
              style: DesignSystem.bodySmall(context).copyWith(
                color: DesignSystem.warning,
              ),
            ),
          if (error != null)
            Text(
              'Error: $error',
              style: DesignSystem.bodySmall(context).copyWith(
                color: DesignSystem.error,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }

  IconData _getOperationIcon(String type) {
    switch (type) {
      case 'createDonation':
        return Icons.add_circle_outline;
      case 'updateDonation':
        return Icons.edit_outlined;
      case 'deleteDonation':
        return Icons.delete_outline;
      case 'createRequest':
        return Icons.add_box_outlined;
      case 'sendMessage':
        return Icons.message_outlined;
      case 'updateProfile':
        return Icons.person_outline;
      case 'uploadImage':
        return Icons.image_outlined;
      default:
        return Icons.sync;
    }
  }

  String _getOperationTitle(String type) {
    switch (type) {
      case 'createDonation':
        return 'Create Donation';
      case 'updateDonation':
        return 'Update Donation';
      case 'deleteDonation':
        return 'Delete Donation';
      case 'createRequest':
        return 'Create Request';
      case 'updateRequest':
        return 'Update Request';
      case 'deleteRequest':
        return 'Delete Request';
      case 'sendMessage':
        return 'Send Message';
      case 'updateProfile':
        return 'Update Profile';
      case 'uploadImage':
        return 'Upload Image';
      default:
        return type;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  Future<void> _syncNow() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isSyncing = true;
    });

    try {
      await _offlineService.forceSync();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.syncCompletedSuccessfully),
            backgroundColor: DesignSystem.success,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.syncFailed(error.toString())),
            backgroundColor: DesignSystem.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }
    }
  }
}

/// Offline status widget for settings/debug
class OfflineStatusWidget extends StatelessWidget {
  const OfflineStatusWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<NetworkStatusService>(
      builder: (context, networkService, child) {
        final offlineService = OfflineService();
        final status = offlineService.getStatus();

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(DesignSystem.spaceL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      networkService.isOnline ? Icons.wifi : Icons.wifi_off,
                      color: networkService.isOnline
                          ? DesignSystem.success
                          : DesignSystem.error,
                    ),
                    const SizedBox(width: DesignSystem.spaceM),
                    Text(
                      'Offline Status',
                      style: DesignSystem.titleMedium(context),
                    ),
                  ],
                ),
                const SizedBox(height: DesignSystem.spaceL),
                _buildStatusRow(
                  context,
                  'Connection',
                  networkService.isOnline ? 'Online' : 'Offline',
                  networkService.isOnline
                      ? DesignSystem.success
                      : DesignSystem.error,
                ),
                _buildStatusRow(
                  context,
                  'Pending Operations',
                  '${status['pendingOperations']}',
                  status['pendingOperations'] > 0
                      ? DesignSystem.warning
                      : DesignSystem.textSecondary,
                ),
                _buildStatusRow(
                  context,
                  'Cached Items',
                  '${status['cacheSize']}',
                  DesignSystem.textSecondary,
                ),
                const SizedBox(height: DesignSystem.spaceL),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: networkService.isOnline
                            ? () => offlineService.forceSync()
                            : null,
                        child: Text(l10n.forceSync),
                      ),
                    ),
                    const SizedBox(width: DesignSystem.spaceM),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => offlineService.clearCache(),
                        child: Text(l10n.clearCache),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusRow(
      BuildContext context, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DesignSystem.spaceXS),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: DesignSystem.bodyMedium(context).copyWith(
              color: DesignSystem.textSecondary,
            ),
          ),
          Text(
            value,
            style: DesignSystem.bodyMedium(context).copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
