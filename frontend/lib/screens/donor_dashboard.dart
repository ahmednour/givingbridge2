import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/custom_input.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class DonorDashboard extends StatefulWidget {
  const DonorDashboard({Key? key}) : super(key: key);

  @override
  State<DonorDashboard> createState() => _DonorDashboardState();
}

class _DonorDashboardState extends State<DonorDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<Map<String, dynamic>> _donations = [];
  bool _isLoading = false;
  bool _showAddForm = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserDonations();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserDonations() async {
    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user != null) {
      final response = await ApiService.getMyDonations();
      if (response.success && mounted) {
        setState(() {
          _donations = List<Map<String, dynamic>>.from(response.data ?? []);
        });
      }
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 768;

    return Scaffold(
      body: Column(
        children: [
          // Tab Bar
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSurfaceColor : AppTheme.surfaceColor,
              border: Border(
                bottom: BorderSide(
                  color:
                      isDark ? AppTheme.darkBorderColor : AppTheme.borderColor,
                  width: 1,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppTheme.primaryColor,
              unselectedLabelColor: isDark
                  ? AppTheme.darkTextSecondaryColor
                  : AppTheme.textSecondaryColor,
              indicatorColor: AppTheme.primaryColor,
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'My Donations'),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(context, theme, isDark, isDesktop),
                _buildDonationsTab(context, theme, isDark, isDesktop),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => setState(() => _showAddForm = !_showAddForm),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        icon: Icon(_showAddForm ? Icons.close : Icons.add),
        label: Text(_showAddForm ? 'Cancel' : 'Add Donation'),
      ),
    );
  }

  Widget _buildOverviewTab(
      BuildContext context, ThemeData theme, bool isDark, bool isDesktop) {
    if (_showAddForm) {
      return _buildAddDonationForm(context, theme, isDark, isDesktop);
    }

    return SingleChildScrollView(
      padding:
          EdgeInsets.all(isDesktop ? AppTheme.spacingL : AppTheme.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          _buildWelcomeSection(context, theme),

          const SizedBox(height: AppTheme.spacingL),

          // Stats Cards
          _buildStatsSection(context, theme, isDesktop),

          const SizedBox(height: AppTheme.spacingL),

          // Recent Activity
          _buildRecentActivity(context, theme, isDark),

          const SizedBox(height: AppTheme.spacingL),

          // Quick Actions
          _buildQuickActions(context, theme, isDesktop),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context, ThemeData theme) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userName = authProvider.user?.name ?? 'Donor';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back, $userName!',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        Text(
          'Thank you for making a difference in your community.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.brightness == Brightness.dark
                ? AppTheme.darkTextSecondaryColor
                : AppTheme.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection(
      BuildContext context, ThemeData theme, bool isDesktop) {
    final stats = [
      {
        'title': 'Total Donations',
        'value': _donations.length.toString(),
        'icon': Icons.volunteer_activism,
        'color': AppTheme.primaryColor,
      },
      {
        'title': 'Active Donations',
        'value': _donations
            .where((d) => d['status'] == 'available')
            .length
            .toString(),
        'icon': Icons.check_circle,
        'color': AppTheme.successColor,
      },
      {
        'title': 'Completed',
        'value': _donations
            .where((d) => d['status'] == 'completed')
            .length
            .toString(),
        'icon': Icons.handshake,
        'color': AppTheme.secondaryColor,
      },
      {
        'title': 'People Helped',
        'value': _donations
            .where((d) => d['status'] == 'completed')
            .length
            .toString(),
        'icon': Icons.people,
        'color': AppTheme.warningColor,
      },
    ];

    if (isDesktop) {
      return Row(
        children: stats.map((stat) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: AppTheme.spacingL),
              child: AppCard(
                variant: CardVariant.filled,
                title: stat['title'] as String,
                value: stat['value'] as String,
                icon: stat['icon'] as IconData,
                iconColor: stat['color'] as Color,
              ),
            ),
          );
        }).toList(),
      );
    } else {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppTheme.spacingL,
          mainAxisSpacing: AppTheme.spacingL,
          childAspectRatio: 1.2,
        ),
        itemCount: stats.length,
        itemBuilder: (context, index) {
          final stat = stats[index];
          return AppCard(
            variant: CardVariant.filled,
            title: stat['title'] as String,
            value: stat['value'] as String,
            icon: stat['icon'] as IconData,
            iconColor: stat['color'] as Color,
          );
        },
      );
    }
  }

  Widget _buildRecentActivity(
      BuildContext context, ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            AppButton(
              variant: ButtonVariant.ghost,
              text: 'View All',
              size: ButtonSize.small,
              onPressed: () => _tabController.animateTo(1),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingL),
        if (_donations.isEmpty)
          AppCard(
            variant: CardVariant.filled,
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.inventory_outlined,
                    size: 48,
                    color: isDark
                        ? AppTheme.darkTextSecondaryColor
                        : AppTheme.textSecondaryColor,
                  ),
                  const SizedBox(height: AppTheme.spacingM), // Spacer?
                  Text(
                    'No donations yet',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isDark
                          ? AppTheme.darkTextSecondaryColor
                          : AppTheme.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  Text(
                    'Start by creating your first donation!',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? AppTheme.darkTextSecondaryColor
                          : AppTheme.textSecondaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          ...(_donations.take(3).map(
                (donation) => Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
                  child: _buildDonationCard(donation, theme, isDark,
                      compact: true),
                ),
              )),
      ],
    );
  }

  Widget _buildQuickActions(
      BuildContext context, ThemeData theme, bool isDesktop) {
    final actions = [
      {
        'title': 'Add Donation',
        'description': 'Share items with those in need',
        'icon': Icons.add_circle_outline,
        'color': AppTheme.primaryColor,
        'onTap': () => setState(() => _showAddForm = true),
      },
      {
        'title': 'Browse Requests',
        'description': 'See what people need',
        'icon': Icons.search_outlined,
        'color': AppTheme.secondaryColor,
        'onTap': () {},
      },
      {
        'title': 'My Impact',
        'description': 'View your contribution stats',
        'icon': Icons.analytics_outlined,
        'color': AppTheme.warningColor,
        'onTap': () {},
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppTheme.spacingL),
        if (isDesktop)
          Row(
            children: actions.map((action) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: AppTheme.spacingL),
                  child: _buildActionCard(action, theme),
                ),
              );
            }).toList(),
          )
        else
          ...actions.map(
            (action) => Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
              child: _buildActionCard(action, theme),
            ),
          ),
      ],
    );
  }

  Widget _buildActionCard(Map<String, dynamic> action, ThemeData theme) {
    return AppCard(
      variant: CardVariant.filled,
      isHoverable: true,
      onTap: action['onTap'],
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: (action['color'] as Color).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusL),
            ),
            child: Icon(
              action['icon'],
              color: action['color'],
              size: 24,
            ),
          ),
          const SizedBox(width: AppTheme.spacingL),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  action['title'],
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  action['description'],
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.brightness == Brightness.dark
                        ? AppTheme.darkTextSecondaryColor
                        : AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: theme.brightness == Brightness.dark
                ? AppTheme.darkTextSecondaryColor
                : AppTheme.textSecondaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildDonationsTab(
      BuildContext context, ThemeData theme, bool isDark, bool isDesktop) {
    return RefreshIndicator(
      onRefresh: _loadUserDonations,
      child: SingleChildScrollView(
        padding:
            EdgeInsets.all(isDesktop ? AppTheme.spacingL : AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Donations',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                AppButton(
                  variant: ButtonVariant.secondary,
                  text: 'Add New',
                  size: ButtonSize.small,
                  leftIcon: const Icon(Icons.add, size: 16),
                  onPressed: () => setState(() => _showAddForm = true),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingL),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_donations.isEmpty)
              AppCard(
                variant: CardVariant.filled,
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.inventory_outlined,
                        size: 64,
                        color: isDark
                            ? AppTheme.darkTextSecondaryColor
                            : AppTheme.textSecondaryColor,
                      ),
                      const SizedBox(height: AppTheme.spacingL),
                      Text(
                        'No donations yet',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: isDark
                              ? AppTheme.darkTextSecondaryColor
                              : AppTheme.textSecondaryColor,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingM),
                      Text(
                        'Share your items with those who need them most.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark
                              ? AppTheme.darkTextSecondaryColor
                              : AppTheme.textSecondaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppTheme.spacingM),
                      AppButton(
                        variant: ButtonVariant.primary,
                        text: 'Create First Donation',
                        leftIcon: const Icon(Icons.add, size: 20),
                        onPressed: () => setState(() => _showAddForm = true),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...(_donations.map(
                (donation) => Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spacingL),
                  child: _buildDonationCard(donation, theme, isDark),
                ),
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationCard(
      Map<String, dynamic> donation, ThemeData theme, bool isDark,
      {bool compact = false}) {
    final status = donation['status'] ?? 'available';
    final statusColor = _getStatusColor(status);

    return AppCard(
      variant: CardVariant.filled,
      isHoverable: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image placeholder
              Container(
                width: compact ? 60 : 80,
                height: compact ? 60 : 80,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppTheme.darkSurfaceColor
                      : AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                ),
                child: donation['imageUrl'] != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(AppTheme.radiusM),
                        child: Image.network(
                          donation['imageUrl'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.image_outlined,
                              color: isDark
                                  ? AppTheme.darkTextSecondaryColor
                                  : AppTheme.textSecondaryColor,
                            );
                          },
                        ),
                      )
                    : Icon(
                        Icons.inventory_outlined,
                        color: isDark
                            ? AppTheme.darkTextSecondaryColor
                            : AppTheme.textSecondaryColor,
                        size: compact ? 24 : 32,
                      ),
              ),

              const SizedBox(width: AppTheme.spacingM),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      donation['title'] ?? 'Untitled',
                      style: compact
                          ? theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600)
                          : theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (!compact) ...[
                      const SizedBox(height: AppTheme.spacingM),
                      Text(
                        donation['description'] ?? '',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark
                              ? AppTheme.darkTextSecondaryColor
                              : AppTheme.textSecondaryColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: AppTheme.spacingM),
                    Row(
                      children: [
                        // Category
                        if (donation['category'] != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.spacingM,
                              vertical: AppTheme.spacingM,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(alpha: 0.1),
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusM),
                            ),
                            child: Text(
                              donation['category'],
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppTheme.spacingM),
                        ],

                        // Status
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingM,
                            vertical: AppTheme.spacingM,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusM),
                          ),
                          child: Text(
                            _getStatusLabel(status),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Actions
              if (!compact)
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: isDark
                        ? AppTheme.darkTextSecondaryColor
                        : AppTheme.textSecondaryColor,
                  ),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      // TODO: Implement edit
                    } else if (value == 'delete') {
                      _deleteDonation(donation['id']);
                    }
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddDonationForm(
      BuildContext context, ThemeData theme, bool isDark, bool isDesktop) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final categoryController = TextEditingController();
    final imageController = TextEditingController();
    final conditionController = TextEditingController();
    final locationController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return SingleChildScrollView(
      padding:
          EdgeInsets.all(isDesktop ? AppTheme.spacingL : AppTheme.spacingM),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: AppCard(
          variant: CardVariant.filled,
          padding: const EdgeInsets.all(AppTheme.spacingL),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create New Donation',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingL),
                CustomInput(
                  variant: InputVariant.filled,
                  label: 'Title',
                  hint: 'What are you donating?',
                  controller: titleController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTheme.spacingL),
                TextAreaInput(
                  label: 'Description',
                  hint: 'Describe the item(s) you\'re donating...',
                  controller: descriptionController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTheme.spacingL),
                CustomInput(
                  variant: InputVariant.filled,
                  label: 'Category',
                  hint: 'e.g., Food, Clothes, Books, Electronics',
                  controller: categoryController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a category';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTheme.spacingL),
                CustomInput(
                  variant: InputVariant.filled,
                  label: 'Image URL (Optional)',
                  hint: 'Add a photo URL of your item',
                  controller: imageController,
                ),
                const SizedBox(height: AppTheme.spacingL),
                CustomInput(
                  variant: InputVariant.filled,
                  label: 'Condition',
                  hint: 'e.g., New, Used, Damaged',
                  controller: conditionController,
                ),
                const SizedBox(height: AppTheme.spacingL),
                CustomInput(
                  variant: InputVariant.filled,
                  label: 'Location',
                  hint: 'e.g., Nairobi, Mombasa, Kisumu',
                  controller: locationController,
                ),
                const SizedBox(height: AppTheme.spacingL),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        variant: ButtonVariant.outline,
                        text: 'Cancel',
                        onPressed: () => setState(() => _showAddForm = false),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingM),
                    Expanded(
                      child: AppButton(
                        variant: ButtonVariant.primary,
                        text: 'Create Donation',
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            await _createDonation(
                              titleController.text,
                              descriptionController.text,
                              categoryController.text,
                              conditionController.text,
                              locationController.text,
                              imageController.text.isEmpty
                                  ? null
                                  : imageController.text,
                            );
                          }
                        },
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

  Future<void> _createDonation(
      String title,
      String description,
      String category,
      String condition,
      String location,
      String? imageUrl) async {
    final response = await ApiService.createDonation(
      title: title,
      description: description,
      category: category,
      condition: condition,
      location: location,
      imageUrl: imageUrl,
    );

    if (response.success) {
      setState(() => _showAddForm = false);
      _loadUserDonations();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Donation created successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.error ?? 'Failed to create donation'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _deleteDonation(String donationId) async {
    final response = await ApiService.deleteDonation(donationId);

    if (response.success) {
      _loadUserDonations();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Donation deleted successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.error ?? 'Failed to delete donation'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return AppTheme.successColor;
      case 'pending':
        return AppTheme.warningColor;
      case 'completed':
        return AppTheme.primaryColor;
      case 'cancelled':
        return AppTheme.errorColor;
      default:
        return AppTheme.primaryColor;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return 'Available';
      case 'pending':
        return 'Pending';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }
}
