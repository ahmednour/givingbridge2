import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/disaster_recovery_provider.dart';
import '../widgets/common/gb_card.dart';
import '../widgets/common/gb_button.dart';
import '../widgets/common/gb_loading_indicator.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/date_formatter.dart';

class DisasterRecoveryDashboard extends StatefulWidget {
  const DisasterRecoveryDashboard({Key? key}) : super(key: key);

  @override
  State<DisasterRecoveryDashboard> createState() => _DisasterRecoveryDashboardState();
}

class _DisasterRecoveryDashboardState extends State<DisasterRecoveryDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DisasterRecoveryProvider>().loadRecoveryStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Disaster Recovery'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<DisasterRecoveryProvider>().loadRecoveryStatus();
            },
          ),
        ],
      ),
      body: Consumer<DisasterRecoveryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: GBLoadingIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load recovery status',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.error!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  GBButton(
                    text: 'Retry',
                    onPressed: () {
                      provider.loadRecoveryStatus();
                    },
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRecoveryReadinessCard(provider),
                const SizedBox(height: 16),
                _buildSystemHealthCard(provider),
                const SizedBox(height: 16),
                _buildRecoveryMetricsCard(provider),
                const SizedBox(height: 16),
                _buildRecoveryActionsCard(provider),
                const SizedBox(height: 16),
                _buildRecoveryHistoryCard(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecoveryReadinessCard(DisasterRecoveryProvider provider) {
    final readiness = provider.recoveryStatus?.readiness;
    final isReady = readiness?.ready ?? false;

    return GBCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isReady ? Icons.check_circle : Icons.warning,
                color: isReady ? AppColors.success : AppColors.warning,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recovery Readiness',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      isReady ? 'System is ready for recovery' : 'System is not ready for recovery',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isReady ? AppColors.success : AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (readiness != null) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            _buildReadinessDetails(readiness),
          ],
        ],
      ),
    );
  }

  Widget _buildReadinessDetails(dynamic readiness) {
    return Column(
      children: [
        _buildReadinessItem(
          'Backup Fresh',
          readiness.backupFresh ?? false,
          'Latest backup is within recovery point objective',
        ),
        const SizedBox(height: 8),
        _buildReadinessItem(
          'System Healthy',
          readiness.systemHealthy ?? false,
          'All system components are functioning properly',
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildMetricItem(
                'Backup Age',
                '${readiness.backupAge ?? 0}s',
                'Last backup was taken ${readiness.backupAge ?? 0} seconds ago',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricItem(
                'RPO',
                '${readiness.recoveryPointObjective ?? 0}s',
                'Recovery Point Objective',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReadinessItem(String title, bool status, String description) {
    return Row(
      children: [
        Icon(
          status ? Icons.check_circle : Icons.cancel,
          color: status ? AppColors.success : AppColors.error,
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSystemHealthCard(DisasterRecoveryProvider provider) {
    final health = provider.systemHealth;
    final status = health?.status ?? 'unknown';
    final issues = health?.issues ?? 0;
    final warnings = health?.warnings ?? 0;

    Color statusColor;
    IconData statusIcon;
    
    switch (status) {
      case 'healthy':
        statusColor = AppColors.success;
        statusIcon = Icons.health_and_safety;
        break;
      case 'unhealthy':
        statusColor = AppColors.error;
        statusIcon = Icons.error;
        break;
      default:
        statusColor = AppColors.warning;
        statusIcon = Icons.help_outline;
    }

    return GBCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                statusIcon,
                color: statusColor,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'System Health',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      status.toUpperCase(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              GBButton(
                text: 'Check Health',
                onPressed: provider.isLoading ? null : () {
                  provider.checkSystemHealth();
                },
                size: ButtonSize.small,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  'Issues',
                  '$issues',
                  'Critical issues found',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricItem(
                  'Warnings',
                  '$warnings',
                  'Warnings found',
                ),
              ),
            ],
          ),
          if (health?.timestamp != null) ...[
            const SizedBox(height: 8),
            Text(
              'Last checked: ${DateFormatter.formatDateTime(DateTime.parse(health!.timestamp))}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecoveryMetricsCard(DisasterRecoveryProvider provider) {
    final metrics = provider.recoveryMetrics;

    return GBCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recovery Metrics',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  'RTO',
                  '${metrics?.recoveryTimeObjective ?? 0}s',
                  'Recovery Time Objective',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricItem(
                  'RPO',
                  '${metrics?.recoveryPointObjective ?? 0}s',
                  'Recovery Point Objective',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  'Last Recovery',
                  metrics?.lastRecoveryDuration != null 
                    ? '${metrics!.lastRecoveryDuration}s'
                    : 'Never',
                  'Duration of last recovery',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricItem(
                  'System Health',
                  (metrics?.systemHealth ?? 'unknown').toUpperCase(),
                  'Current system health status',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecoveryActionsCard(DisasterRecoveryProvider provider) {
    return GBCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recovery Actions',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GBButton(
                  text: 'Test Recovery',
                  onPressed: provider.isLoading ? null : () {
                    _showTestRecoveryDialog(provider);
                  },
                  variant: ButtonVariant.secondary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GBButton(
                  text: 'Full Recovery',
                  onPressed: provider.isLoading ? null : () {
                    _showFullRecoveryDialog(provider);
                  },
                  variant: ButtonVariant.danger,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Test Recovery: Safe test of recovery procedures without affecting production data.\n'
            'Full Recovery: DESTRUCTIVE operation that replaces current data with backup.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecoveryHistoryCard(DisasterRecoveryProvider provider) {
    final metrics = provider.recoveryMetrics;

    return GBCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recovery History',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildHistoryItem(
            'Last Recovery Test',
            metrics?.lastTestTime,
            Icons.science,
            AppColors.info,
          ),
          const SizedBox(height: 12),
          _buildHistoryItem(
            'Last Full Recovery',
            metrics?.lastRecoveryTime,
            Icons.restore,
            AppColors.warning,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(String title, String? timestamp, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text(
                timestamp != null 
                  ? DateFormatter.formatDateTime(DateTime.parse(timestamp))
                  : 'Never',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricItem(String title, String value, String description) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _showTestRecoveryDialog(DisasterRecoveryProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Test Recovery Procedures'),
        content: const Text(
          'This will test the disaster recovery procedures without affecting production data. '
          'The test will verify that backups can be restored successfully.\n\n'
          'This operation is safe and will not impact the running system.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              provider.testRecoveryProcedures();
            },
            child: const Text('Start Test'),
          ),
        ],
      ),
    );
  }

  void _showFullRecoveryDialog(DisasterRecoveryProvider provider) {
    final confirmationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: AppColors.error),
            const SizedBox(width: 8),
            const Text('DANGER: Full Recovery'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This will perform a FULL DISASTER RECOVERY operation.',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'WARNING: This operation is DESTRUCTIVE and will:\n'
              '• Replace all current data with backup data\n'
              '• Stop all running services\n'
              '• Restore database from latest backup\n'
              '• Restore files from latest backup\n'
              '• Restart all services\n\n'
              'This cannot be undone!',
            ),
            const SizedBox(height: 16),
            const Text(
              'Type "I_UNDERSTAND_THIS_IS_DESTRUCTIVE" to confirm:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: confirmationController,
              decoration: const InputDecoration(
                hintText: 'Confirmation text',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (confirmationController.text == 'I_UNDERSTAND_THIS_IS_DESTRUCTIVE') {
                Navigator.of(context).pop();
                provider.performFullRecovery();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Confirmation text does not match'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('PERFORM RECOVERY'),
          ),
        ],
      ),
    );
  }
}