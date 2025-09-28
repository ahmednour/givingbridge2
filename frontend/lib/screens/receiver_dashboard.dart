import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_input.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class ReceiverDashboard extends StatefulWidget {
  const ReceiverDashboard({Key? key}) : super(key: key);

  @override
  State<ReceiverDashboard> createState() => _ReceiverDashboardState();
}

class _ReceiverDashboardState extends State<ReceiverDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();

  List<Map<String, dynamic>> _availableDonations = [];
  List<Map<String, dynamic>> _myRequests = [];
  bool _isLoading = false;
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'All',
    'Food',
    'Clothes',
    'Books',
    'Electronics',
    'Furniture',
    'Toys',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadAvailableDonations(),
      _loadMyRequests(),
    ]);
  }

  Future<void> _loadAvailableDonations() async {
    setState(() => _isLoading = true);

    final response = await _apiService.getRequests(
      category:
          _selectedCategory == 'All' ? null : _selectedCategory.toLowerCase(),
      status: 'available',
    );

    if (response['success'] && mounted) {
      setState(() {
        _availableDonations =
            List<Map<String, dynamic>>.from(response['requests'] ?? []);
      });
    }

    setState(() => _isLoading = false);
  }

  Future<void> _loadMyRequests() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user != null) {
      final response = await _apiService.getUserRequests(authProvider.user!.id);
      if (response['success'] && mounted) {
        setState(() {
          _myRequests =
              List<Map<String, dynamic>>.from(response['requests'] ?? []);
        });
      }
    }
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
              color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                  width: 1,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppTheme.primaryColor,
              unselectedLabelColor: isDark
                  ? AppTheme.darkTextSecondary
                  : AppTheme.lightTextSecondary,
              indicatorColor: AppTheme.primaryColor,
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'Browse Donations'),
                Tab(text: 'My Requests'),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBrowseTab(context, theme, isDark, isDesktop),
                _buildRequestsTab(context, theme, isDark, isDesktop),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrowseTab(
      BuildContext context, ThemeData theme, bool isDark, bool isDesktop) {
    return Column(
      children: [
        // Search and Filter Bar
        Container(
          padding: const EdgeInsets.all(AppTheme.spacing16),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
            border: Border(
              bottom: BorderSide(
                color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: [
              // Search Bar
              SearchInput(
                controller: _searchController,
                hint: 'Search donations...',
                onChanged: (value) {
                  // TODO: Implement search
                },
                onClear: () {
                  _searchController.clear();
                  // TODO: Clear search
                },
              ),

              const SizedBox(height: AppTheme.spacing12),

              // Category Filter
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = _selectedCategory == category;

                    return Padding(
                      padding: const EdgeInsets.only(right: AppTheme.spacing8),
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _selectedCategory = category);
                          _loadAvailableDonations();
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacing16,
                            vertical: AppTheme.spacing8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primaryColor
                                : (isDark
                                    ? AppTheme.darkSurfaceVariant
                                    : AppTheme.lightSurfaceVariant),
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusLarge),
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.primaryColor
                                  : (isDark
                                      ? AppTheme.darkBorder
                                      : AppTheme.lightBorder),
                            ),
                          ),
                          child: Text(
                            category,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : (isDark
                                      ? AppTheme.darkTextPrimary
                                      : AppTheme.lightTextPrimary),
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // Donations Grid
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadAvailableDonations,
            child: _buildDonationsGrid(context, theme, isDark, isDesktop),
          ),
        ),
      ],
    );
  }

  Widget _buildDonationsGrid(
      BuildContext context, ThemeData theme, bool isDark, bool isDesktop) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_availableDonations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: isDark
                  ? AppTheme.darkTextTertiary
                  : AppTheme.lightTextTertiary,
            ),
            const SizedBox(height: AppTheme.spacing16),
            Text(
              'No donations found',
              style: theme.textTheme.titleMedium?.copyWith(
                color: isDark
                    ? AppTheme.darkTextSecondary
                    : AppTheme.lightTextSecondary,
              ),
            ),
            const SizedBox(height: AppTheme.spacing8),
            Text(
              'Try adjusting your search or category filter.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? AppTheme.darkTextTertiary
                    : AppTheme.lightTextTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Padding(
      padding:
          EdgeInsets.all(isDesktop ? AppTheme.spacing24 : AppTheme.spacing16),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isDesktop ? 3 : 1,
          crossAxisSpacing: AppTheme.spacing16,
          mainAxisSpacing: AppTheme.spacing16,
          childAspectRatio: isDesktop ? 0.8 : 1.2,
        ),
        itemCount: _availableDonations.length,
        itemBuilder: (context, index) {
          final donation = _availableDonations[index];
          return _buildDonationCard(donation, theme, isDark, isDesktop);
        },
      ),
    );
  }

  Widget _buildDonationCard(Map<String, dynamic> donation, ThemeData theme,
      bool isDark, bool isDesktop) {
    return DonationCard(
      title: donation['title'] ?? 'Untitled',
      description: donation['description'] ?? '',
      imageUrl: donation['imageUrl'],
      category: donation['category'],
      location: donation['location'],
      donorName: donation['donorName'] ?? 'Anonymous',
      onTap: () => _showDonationDetails(donation),
      onRequest: () => _requestDonation(donation),
    );
  }

  Widget _buildRequestsTab(
      BuildContext context, ThemeData theme, bool isDark, bool isDesktop) {
    return RefreshIndicator(
      onRefresh: _loadMyRequests,
      child: SingleChildScrollView(
        padding:
            EdgeInsets.all(isDesktop ? AppTheme.spacing32 : AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Requests',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${_myRequests.length} requests',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppTheme.darkTextSecondary
                        : AppTheme.lightTextSecondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spacing24),

            // Requests List
            if (_myRequests.isEmpty)
              CustomCard(
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 64,
                        color: isDark
                            ? AppTheme.darkTextTertiary
                            : AppTheme.lightTextTertiary,
                      ),
                      const SizedBox(height: AppTheme.spacing16),
                      Text(
                        'No requests yet',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: isDark
                              ? AppTheme.darkTextSecondary
                              : AppTheme.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacing8),
                      Text(
                        'Browse available donations and request what you need.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark
                              ? AppTheme.darkTextTertiary
                              : AppTheme.lightTextTertiary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppTheme.spacing24),
                      PrimaryButton(
                        text: 'Browse Donations',
                        leftIcon: const Icon(Icons.search, size: 20),
                        onPressed: () => _tabController.animateTo(0),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...(_myRequests.map(
                (request) => Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spacing16),
                  child: _buildRequestCard(request, theme, isDark),
                ),
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestCard(
      Map<String, dynamic> request, ThemeData theme, bool isDark) {
    final status = request['status'] ?? 'pending';
    final statusColor = _getStatusColor(status);

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppTheme.darkSurfaceVariant
                      : AppTheme.lightSurfaceVariant,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: request['imageUrl'] != null
                    ? ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusSmall),
                        child: Image.network(
                          request['imageUrl'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.image_outlined,
                              color: isDark
                                  ? AppTheme.darkTextTertiary
                                  : AppTheme.lightTextTertiary,
                            );
                          },
                        ),
                      )
                    : Icon(
                        Icons.inventory_outlined,
                        color: isDark
                            ? AppTheme.darkTextTertiary
                            : AppTheme.lightTextTertiary,
                        size: 32,
                      ),
              ),

              const SizedBox(width: AppTheme.spacing12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request['title'] ?? 'Untitled',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: AppTheme.spacing4),

                    if (request['description'] != null) ...[
                      Text(
                        request['description'],
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark
                              ? AppTheme.darkTextSecondary
                              : AppTheme.lightTextSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppTheme.spacing8),
                    ],

                    // Status and Date
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacing8,
                            vertical: AppTheme.spacing4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusSmall),
                          ),
                          child: Text(
                            _getStatusLabel(status),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacing12),
                        if (request['createdAt'] != null)
                          Text(
                            _formatDate(request['createdAt']),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: isDark
                                  ? AppTheme.darkTextTertiary
                                  : AppTheme.lightTextTertiary,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Actions
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: isDark
                      ? AppTheme.darkTextTertiary
                      : AppTheme.lightTextTertiary,
                ),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'view',
                    child: Text('View Details'),
                  ),
                  if (status == 'pending') ...[
                    const PopupMenuItem(
                      value: 'cancel',
                      child: Text('Cancel Request'),
                    ),
                  ],
                ],
                onSelected: (value) {
                  if (value == 'view') {
                    _showRequestDetails(request);
                  } else if (value == 'cancel') {
                    _cancelRequest(request);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDonationDetails(Map<String, dynamic> donation) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildDonationDetailsSheet(donation),
    );
  }

  Widget _buildDonationDetailsSheet(Map<String, dynamic> donation) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppTheme.radiusLarge),
          topRight: Radius.circular(AppTheme.radiusLarge),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: AppTheme.spacing12),
            decoration: BoxDecoration(
              color: isDark
                  ? AppTheme.darkTextTertiary
                  : AppTheme.lightTextTertiary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacing24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  if (donation['imageUrl'] != null) ...[
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMedium),
                      ),
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMedium),
                        child: Image.network(
                          donation['imageUrl'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: isDark
                                  ? AppTheme.darkSurfaceVariant
                                  : AppTheme.lightSurfaceVariant,
                              child: Icon(
                                Icons.image_outlined,
                                size: 64,
                                color: isDark
                                    ? AppTheme.darkTextTertiary
                                    : AppTheme.lightTextTertiary,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing24),
                  ],

                  // Title
                  Text(
                    donation['title'] ?? 'Untitled',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: AppTheme.spacing16),

                  // Description
                  if (donation['description'] != null) ...[
                    Text(
                      donation['description'],
                      style: theme.textTheme.bodyLarge?.copyWith(
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing24),
                  ],

                  // Details
                  _buildDetailRow('Category',
                      donation['category'] ?? 'Not specified', theme, isDark),
                  _buildDetailRow('Location',
                      donation['location'] ?? 'Not specified', theme, isDark),
                  _buildDetailRow('Donor', donation['donorName'] ?? 'Anonymous',
                      theme, isDark),
                  _buildDetailRow('Posted', _formatDate(donation['createdAt']),
                      theme, isDark),

                  const SizedBox(height: AppTheme.spacing32),

                  // Request Button
                  PrimaryButton(
                    text: 'Request This Item',
                    width: double.infinity,
                    size: ButtonSize.large,
                    leftIcon: const Icon(Icons.handshake, size: 20),
                    onPressed: () {
                      Navigator.pop(context);
                      _requestDonation(donation);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
      String label, String? value, ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacing12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? AppTheme.darkTextSecondary
                    : AppTheme.lightTextSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'Not specified',
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  void _showRequestDetails(Map<String, dynamic> request) {
    // TODO: Implement request details
  }

  Future<void> _requestDonation(Map<String, dynamic> donation) async {
    // TODO: Implement request donation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Request sent successfully!'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  Future<void> _cancelRequest(Map<String, dynamic> request) async {
    // TODO: Implement cancel request
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Request cancelled'),
        backgroundColor: AppTheme.warningColor,
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppTheme.warningColor;
      case 'approved':
        return AppTheme.successColor;
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
      case 'pending':
        return 'Pending';
      case 'approved':
        return 'Approved';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 7) {
        return '${date.day}/${date.month}/${date.year}';
      } else if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown';
    }
  }
}
