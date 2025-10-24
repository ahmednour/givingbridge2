import 'package:flutter/material.dart';
import '../../core/constants/ui_constants.dart';
import '../../core/theme/app_theme_enhanced.dart';
import '../../core/utils/rtl_utils.dart';
import '../../l10n/app_localizations.dart';
import '../common/web_card.dart';

/// Admin dashboard statistics card widget
class AdminStatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const AdminStatsCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isRTL = RTLUtils.isRTL(context);

    return WebCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment:
            isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: UIConstants.iconL,
                height: UIConstants.iconL,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(UIConstants.radiusM),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: UIConstants.iconM,
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: AppTheme.textHintColor,
                size: UIConstants.iconS,
              ),
            ],
          ),
          SizedBox(height: UIConstants.spacingM),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.textPrimaryColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: UIConstants.spacingS),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
          ),
        ],
      ),
    );
  }
}

/// Admin dashboard quick actions widget
class AdminQuickActions extends StatelessWidget {
  const AdminQuickActions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isRTL = RTLUtils.isRTL(context);

    final actions = [
      {
        'title': l10n.userManagement,
        'icon': Icons.people,
        'color': AppTheme.primaryColor,
        'onTap': () {
          // Navigate to user management
        },
      },
      {
        'title': l10n.donationManagement,
        'icon': Icons.inventory,
        'color': AppTheme.secondaryColor,
        'onTap': () {
          // Navigate to donation management
        },
      },
      {
        'title': l10n.requestManagement,
        'icon': Icons.request_page,
        'color': AppTheme.accentColor,
        'onTap': () {
          // Navigate to request management
        },
      },
      {
        'title': l10n.analytics,
        'icon': Icons.analytics,
        'color': AppTheme.successColor,
        'onTap': () {
          // Navigate to analytics
        },
      },
    ];

    return WebCard(
      child: Column(
        crossAxisAlignment:
            isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            'الإجراءات السريعة',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: UIConstants.spacingL),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              crossAxisSpacing: UIConstants.spacingM,
              mainAxisSpacing: UIConstants.spacingM,
            ),
            itemCount: actions.length,
            itemBuilder: (context, index) {
              final action = actions[index];
              return InkWell(
                onTap: action['onTap'] as VoidCallback,
                borderRadius: BorderRadius.circular(UIConstants.radiusM),
                child: Container(
                  padding: EdgeInsets.all(UIConstants.spacingM),
                  decoration: BoxDecoration(
                    color: (action['color'] as Color).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(UIConstants.radiusM),
                    border: Border.all(
                      color: (action['color'] as Color).withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        action['icon'] as IconData,
                        color: action['color'] as Color,
                        size: UIConstants.iconM,
                      ),
                      SizedBox(width: UIConstants.spacingS),
                      Expanded(
                        child: Text(
                          action['title'] as String,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Recent activity widget for admin dashboard
class AdminRecentActivity extends StatelessWidget {
  const AdminRecentActivity({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isRTL = RTLUtils.isRTL(context);

    // Mock data - in real app, this would come from a provider
    final activities = [
      {
        'type': 'donation',
        'title': 'تبرع جديد: كتب تعليمية',
        'user': 'أحمد محمد',
        'time': 'منذ 5 دقائق',
        'icon': Icons.inventory,
        'color': AppTheme.primaryColor,
      },
      {
        'type': 'request',
        'title': 'طلب جديد: ملابس شتوية',
        'user': 'فاطمة أحمد',
        'time': 'منذ 15 دقيقة',
        'icon': Icons.request_page,
        'color': AppTheme.secondaryColor,
      },
      {
        'type': 'user',
        'title': 'مستخدم جديد انضم',
        'user': 'محمد علي',
        'time': 'منذ 30 دقيقة',
        'icon': Icons.person_add,
        'color': AppTheme.accentColor,
      },
      {
        'type': 'donation',
        'title': 'تبرع مكتمل: أجهزة إلكترونية',
        'user': 'سارة محمد',
        'time': 'منذ ساعة',
        'icon': Icons.check_circle,
        'color': AppTheme.successColor,
      },
    ];

    return WebCard(
      child: Column(
        crossAxisAlignment:
            isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'النشاط الأخير',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to full activity log
                },
                child: Text('عرض الكل'),
              ),
            ],
          ),
          SizedBox(height: UIConstants.spacingL),
          ...activities.map((activity) {
            return Container(
              margin: EdgeInsets.only(bottom: UIConstants.spacingM),
              padding: EdgeInsets.all(UIConstants.spacingM),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(UIConstants.radiusM),
              ),
              child: Row(
                children: [
                  Container(
                    width: UIConstants.iconM,
                    height: UIConstants.iconM,
                    decoration: BoxDecoration(
                      color: (activity['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(UIConstants.radiusS),
                    ),
                    child: Icon(
                      activity['icon'] as IconData,
                      color: activity['color'] as Color,
                      size: UIConstants.iconS,
                    ),
                  ),
                  SizedBox(width: UIConstants.spacingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: isRTL
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity['title'] as String,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                        SizedBox(height: UIConstants.spacingXS),
                        Row(
                          children: [
                            Text(
                              activity['user'] as String,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppTheme.textSecondaryColor,
                                  ),
                            ),
                            SizedBox(width: UIConstants.spacingS),
                            Text(
                              '•',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppTheme.textHintColor,
                                  ),
                            ),
                            SizedBox(width: UIConstants.spacingS),
                            Text(
                              activity['time'] as String,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppTheme.textSecondaryColor,
                                  ),
                            ),
                          ],
                        ),
                      ],
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
}

/// Admin dashboard overview widget
class AdminDashboardOverview extends StatelessWidget {
  const AdminDashboardOverview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        // Statistics Cards
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          crossAxisSpacing: UIConstants.spacingM,
          mainAxisSpacing: UIConstants.spacingM,
          children: [
            AdminStatsCard(
              title: l10n.totalUsers,
              value: '1,234',
              icon: Icons.people,
              color: AppTheme.primaryColor,
              onTap: () {
                // Navigate to users
              },
            ),
            AdminStatsCard(
              title: l10n.totalDonations,
              value: '5,678',
              icon: Icons.inventory,
              color: AppTheme.secondaryColor,
              onTap: () {
                // Navigate to donations
              },
            ),
            AdminStatsCard(
              title: l10n.totalRequests,
              value: '2,345',
              icon: Icons.request_page,
              color: AppTheme.accentColor,
              onTap: () {
                // Navigate to requests
              },
            ),
            AdminStatsCard(
              title: l10n.activeUsers,
              value: '890',
              icon: Icons.trending_up,
              color: AppTheme.successColor,
              onTap: () {
                // Navigate to analytics
              },
            ),
          ],
        ),
        SizedBox(height: UIConstants.spacingL),

        // Quick Actions
        const AdminQuickActions(),
        SizedBox(height: UIConstants.spacingL),

        // Recent Activity
        const AdminRecentActivity(),
      ],
    );
  }
}
