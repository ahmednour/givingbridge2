import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../services/api_service.dart';
import '../models/donation.dart';

class DonorImpactScreen extends StatefulWidget {
  const DonorImpactScreen({Key? key}) : super(key: key);

  @override
  State<DonorImpactScreen> createState() => _DonorImpactScreenState();
}

class _DonorImpactScreenState extends State<DonorImpactScreen> {
  bool _isLoading = true;
  List<Donation> _donations = [];
  Map<String, int> _categoryBreakdown = {};
  int _totalDonations = 0;
  int _activeDonations = 0;
  int _completedDonations = 0;
  int _totalRequests = 0;

  @override
  void initState() {
    super.initState();
    _loadImpactData();
  }

  Future<void> _loadImpactData() async {
    setState(() => _isLoading = true);

    try {
      // Load user's donations
      final donationsResponse = await ApiService.getMyDonations();
      if (donationsResponse.success) {
        _donations = donationsResponse.data ?? [];

        // Calculate statistics
        _totalDonations = _donations.length;
        _activeDonations = _donations.where((d) => d.isAvailable).length;
        _completedDonations = _donations.where((d) => !d.isAvailable).length;

        // Calculate category breakdown
        _categoryBreakdown = {};
        for (var donation in _donations) {
          _categoryBreakdown[donation.category] =
              (_categoryBreakdown[donation.category] ?? 0) + 1;
        }
      }

      // Load requests for donations
      final requestsResponse = await ApiService.getIncomingRequests();
      if (requestsResponse.success) {
        final requests = requestsResponse.data ?? [];
        _totalRequests = requests.length;
      }
    } catch (e) {
      print('Error loading impact data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 768;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myImpact),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: AppTheme.backgroundColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _totalDonations == 0
              ? _buildEmptyState(l10n)
              : SingleChildScrollView(
                  padding: EdgeInsets.all(isDesktop ? 32.0 : 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Text(
                        l10n.contributionStatistics,
                        style: TextStyle(
                          fontSize: isDesktop ? 32 : 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.allTime,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Statistics Grid
                      _buildStatisticsGrid(l10n, isDesktop),

                      const SizedBox(height: 32),

                      // Category Breakdown
                      _buildCategoryBreakdown(l10n, isDesktop),

                      const SizedBox(height: 32),

                      // Recent Activity
                      _buildRecentActivity(l10n, isDesktop),
                    ],
                  ),
                ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 120,
              color: AppTheme.textSecondaryColor.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.noActivityYet,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.startDonating,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsGrid(AppLocalizations l10n, bool isDesktop) {
    final stats = [
      {
        'title': l10n.totalDonationsMade,
        'value': _totalDonations.toString(),
        'icon': Icons.volunteer_activism,
        'color': AppTheme.primaryColor,
      },
      {
        'title': l10n.activeDonations,
        'value': _activeDonations.toString(),
        'icon': Icons.local_shipping,
        'color': AppTheme.successColor,
      },
      {
        'title': l10n.completedDonations,
        'value': _completedDonations.toString(),
        'icon': Icons.check_circle,
        'color': const Color(0xFF8B5CF6),
      },
      {
        'title': l10n.totalRequests,
        'value': _totalRequests.toString(),
        'icon': Icons.people,
        'color': AppTheme.warningColor,
      },
    ];

    if (isDesktop) {
      return Row(
        children: stats.map((stat) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: _buildStatCard(stat),
            ),
          );
        }).toList(),
      );
    }

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: stats.map((stat) => _buildStatCard(stat)).toList(),
    );
  }

  Widget _buildStatCard(Map<String, dynamic> stat) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (stat['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              stat['icon'] as IconData,
              color: stat['color'] as Color,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            stat['value'] as String,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            stat['title'] as String,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown(AppLocalizations l10n, bool isDesktop) {
    if (_categoryBreakdown.isEmpty) return const SizedBox.shrink();

    final colors = [
      AppTheme.primaryColor,
      AppTheme.successColor,
      AppTheme.warningColor,
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      const Color(0xFF06B6D4),
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.categoryBreakdown,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 24),
          ...List.generate(_categoryBreakdown.length, (index) {
            final entry = _categoryBreakdown.entries.elementAt(index);
            final percentage =
                (entry.value / _totalDonations * 100).toStringAsFixed(0);
            final color = colors[index % colors.length];

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            entry.key.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimaryColor,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '$percentage%',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: entry.value / _totalDonations,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(AppLocalizations l10n, bool isDesktop) {
    final recentDonations = _donations.take(5).toList();

    if (recentDonations.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.recentActivity,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 24),
          ...recentDonations.map((donation) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getCategoryIcon(donation.category),
                      color: AppTheme.primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          donation.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimaryColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          donation.category.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: donation.isAvailable
                          ? AppTheme.successColor.withOpacity(0.1)
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      donation.isAvailable ? 'Active' : 'Completed',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: donation.isAvailable
                            ? AppTheme.successColor
                            : AppTheme.textSecondaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'clothes':
        return Icons.checkroom;
      case 'books':
        return Icons.menu_book;
      case 'electronics':
        return Icons.devices;
      default:
        return Icons.category;
    }
  }
}
