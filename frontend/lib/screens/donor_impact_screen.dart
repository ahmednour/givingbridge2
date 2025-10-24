import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/design_system.dart';
import '../widgets/common/gb_empty_state.dart';
import '../widgets/common/web_card.dart';
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
    Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 768;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myImpact),
        backgroundColor: DesignSystem.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: DesignSystem.getBackgroundColor(context),
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
                          color: DesignSystem.textPrimary,
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: -0.1, end: 0),
                      const SizedBox(height: 8),
                      Text(
                        l10n.allTime,
                        style: const TextStyle(
                          fontSize: 16,
                          color: DesignSystem.textSecondary,
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
    return GBEmptyState(
      icon: Icons.analytics_outlined,
      title: l10n.noActivityYet,
      message: l10n.startDonating,
    );
  }

  Widget _buildStatisticsGrid(AppLocalizations l10n, bool isDesktop) {
    final stats = [
      {
        'title': l10n.totalDonationsMade,
        'value': _totalDonations.toString(),
        'icon': Icons.volunteer_activism,
        'color': DesignSystem.primaryBlue,
      },
      {
        'title': l10n.activeDonations,
        'value': _activeDonations.toString(),
        'icon': Icons.local_shipping,
        'color': DesignSystem.success,
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
        'color': DesignSystem.warning,
      },
    ];

    if (isDesktop) {
      return Row(
        children: stats.asMap().entries.map((entry) {
          final index = entry.key;
          final stat = entry.value;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: _buildStatCard(stat, index),
            ),
          );
        }).toList(),
      )
          .animate()
          .fadeIn(duration: 400.ms, delay: 100.ms)
          .slideY(begin: 0.1, end: 0);
    }

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: stats.asMap().entries.map((entry) {
        final index = entry.key;
        final stat = entry.value;
        return _buildStatCard(stat, index)
            .animate(delay: (index * 100).ms)
            .fadeIn(duration: 300.ms)
            .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1));
      }).toList(),
    );
  }

  Widget _buildStatCard(Map<String, dynamic> stat, int index) {
    return WebCard(
      padding: const EdgeInsets.all(20),
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
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: DesignSystem.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            stat['title'] as String,
            style: const TextStyle(
              fontSize: 14,
              color: DesignSystem.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown(AppLocalizations l10n, bool isDesktop) {
    if (_categoryBreakdown.isEmpty) return const SizedBox.shrink();

    final colors = [
      DesignSystem.primaryBlue,
      DesignSystem.success,
      DesignSystem.warning,
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      const Color(0xFF06B6D4),
    ];

    return WebCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.categoryBreakdown,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: DesignSystem.textPrimary,
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
                              color: DesignSystem.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '$percentage%',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: DesignSystem.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: entry.value / _totalDonations,
                      backgroundColor: DesignSystem.neutral200,
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
    )
        .animate(delay: 200.ms)
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.1, end: 0);
  }

  Widget _buildRecentActivity(AppLocalizations l10n, bool isDesktop) {
    final recentDonations = _donations.take(5).toList();

    if (recentDonations.isEmpty) return const SizedBox.shrink();

    return WebCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.recentActivity,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: DesignSystem.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          ...recentDonations.asMap().entries.map((entry) {
            final index = entry.key;
            final donation = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: DesignSystem.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getCategoryIcon(donation.category),
                      color: DesignSystem.primaryBlue,
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
                            color: DesignSystem.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          donation.category.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: DesignSystem.textSecondary,
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
                          ? DesignSystem.success.withOpacity(0.1)
                          : DesignSystem.neutral200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      donation.isAvailable ? 'Active' : 'Completed',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: donation.isAvailable
                            ? DesignSystem.success
                            : DesignSystem.textSecondary,
                      ),
                    ),
                  ),
                ],
              )
                  .animate(delay: (index * 100).ms)
                  .fadeIn(duration: 300.ms)
                  .slideX(begin: 0.1, end: 0),
            );
          }).toList(),
        ],
      ),
    )
        .animate(delay: 300.ms)
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.1, end: 0);
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
