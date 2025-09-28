import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../widgets/app_button.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart';
import '../models/donation.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({Key? key}) : super(key: key);

  @override
  _AdminPanelScreenState createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  bool _isLoading = true;

  // Statistics
  int _totalUsers = 0;
  int _totalDonations = 0;
  int _totalRequests = 0;
  int _totalMessages = 0;
  int _pendingRequests = 0;
  int _availableDonations = 0;

  // Data lists
  List<User> _users = [];
  List<Donation> _donations = [];
  List<DonationRequest> _requests = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load statistics and data in parallel
      await Future.wait([
        _loadUsers(),
        _loadDonations(),
        _loadRequests(),
        _loadStatistics(),
      ]);
    } catch (e) {
      _showErrorSnackbar('Failed to load admin data: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUsers() async {
    try {
      final response = await ApiService.getAllUsers();
      if (response.success && response.data != null) {
        setState(() {
          _users = response.data!;
          _totalUsers = _users.length;
        });
      }
    } catch (e) {
      print('Error loading users: $e');
    }
  }

  Future<void> _loadDonations() async {
    try {
      final response = await ApiService.getDonations();
      if (response.success && response.data != null) {
        setState(() {
          _donations = response.data!;
          _totalDonations = _donations.length;
          _availableDonations = _donations.where((d) => d.isAvailable ?? false).length;
        });
      }
    } catch (e) {
      print('Error loading donations: $e');
    }
  }

  Future<void> _loadRequests() async {
    try {
      final response = await ApiService.getRequests();
      if (response.success && response.data != null) {
        setState(() {
          _requests = response.data!;
          _totalRequests = _requests.length;
          _pendingRequests = _requests.where((r) => r.isPending ?? false).length;
        });
      }
    } catch (e) {
      print('Error loading requests: $e');
    }
  }

  Future<void> _loadStatistics() async {
    // This would load message statistics if available
    setState(() {
      _totalMessages = 0; // Placeholder
    });
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Admin Panel',
          style: TextStyle(
            color: AppTheme.textPrimaryColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.textSecondaryColor,
          indicatorColor: AppTheme.primaryColor,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Users'),
            Tab(text: 'Donations'),
            Tab(text: 'Requests'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildUsersTab(),
                _buildDonationsTab(),
                _buildRequestsTab(),
              ],
            ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Statistics Cards
          _buildStatsGrid(),

          const SizedBox(height: AppTheme.spacingL),

          // Recent Activity
          Text(
            'Platform Overview',
            style: AppTheme.headingMedium,
          ),
          const SizedBox(height: AppTheme.spacingM),

          _buildOverviewCard(
            'User Distribution',
            [
              _buildStatRow('Donors', _users.where((u) => u.isDonor ?? false).length),
              _buildStatRow(
                  'Receivers', _users.where((u) => u.isReceiver ?? false).length),
              _buildStatRow('Admins', _users.where((u) => u.isAdmin ?? false).length),
            ],
            Icons.people,
          ),

          const SizedBox(height: AppTheme.spacingM),

          _buildOverviewCard(
            'Donation Status',
            [
              _buildStatRow('Available', _availableDonations),
              _buildStatRow(
                  'Unavailable', _totalDonations - _availableDonations),
              _buildStatRow(
                  'Completion Rate',
                  _totalRequests > 0
                      ? '${((_requests.where((r) => r.isCompleted ?? false).length / _totalRequests) * 100).toInt()}%'
                      : '0%'),
            ],
            Icons.volunteer_activism,
          ),

          const SizedBox(height: AppTheme.spacingM),

          _buildOverviewCard(
            'Request Activity',
            [
              _buildStatRow('Pending', _pendingRequests),
              _buildStatRow(
                  'Approved', _requests.where((r) => r.isApproved ?? false).length),
              _buildStatRow(
                  'Completed', _requests.where((r) => r.isCompleted ?? false).length),
            ],
            Icons.inbox,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    final stats = [
      {
        'title': 'Total Users',
        'value': _totalUsers.toString(),
        'icon': Icons.people,
        'color': Colors.blue
      },
      {
        'title': 'Total Donations',
        'value': _totalDonations.toString(),
        'icon': Icons.volunteer_activism,
        'color': Colors.green
      },
      {
        'title': 'Pending Requests',
        'value': _pendingRequests.toString(),
        'icon': Icons.pending,
        'color': Colors.orange
      },
      {
        'title': 'Available Donations',
        'value': _availableDonations.toString(),
        'icon': Icons.check_circle,
        'color': Colors.purple
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppTheme.spacingM,
        mainAxisSpacing: AppTheme.spacingM,
        childAspectRatio: 1.5,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Container(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusL),
            boxShadow: AppTheme.shadowMD,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingS),
                    decoration: BoxDecoration(
                      color: (stat['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusS),
                    ),
                    child: Icon(
                      stat['icon'] as IconData,
                      color: stat['color'] as Color,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                stat['value'] as String,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              const SizedBox(height: AppTheme.spacingXS),
              Text(
                stat['title'] as String,
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOverviewCard(
      String title, List<Widget> children, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        boxShadow: AppTheme.shadowMD,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primaryColor),
              const SizedBox(width: AppTheme.spacingS),
              Text(title, style: AppTheme.headingSmall),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          ...children,
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingS),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTheme.bodyMedium),
          Text(
            value.toString(),
            style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          return _buildUserCard(user);
        },
      ),
    );
  }

  Widget _buildUserCard(User user) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        boxShadow: AppTheme.shadowMD,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: _getRoleColor(user.role).withOpacity(0.1),
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
              style: TextStyle(
                color: _getRoleColor(user.role),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: AppTheme.headingSmall.copyWith(fontSize: 16),
                ),
                const SizedBox(height: AppTheme.spacingXS),
                Text(
                  user.email,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXS),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingS,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getRoleColor(user.role).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusS),
                  ),
                  child: Text(
                    user.role.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _getRoleColor(user.role),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatDate(user.createdAt),
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonationsTab() {
    return RefreshIndicator(
      onRefresh: _loadDonations,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        itemCount: _donations.length,
        itemBuilder: (context, index) {
          final donation = _donations[index];
          return _buildDonationCard(donation);
        },
      ),
    );
  }

  Widget _buildDonationCard(Donation donation) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        boxShadow: AppTheme.shadowMD,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingS,
                  vertical: AppTheme.spacingXS,
                ),
                decoration: BoxDecoration(
                  color: donation.isAvailable
                      ? Colors.green.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusS),
                ),
                child: Text(
                  donation.isAvailable ? 'Available' : 'Unavailable',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: donation.isAvailable ? Colors.green : Colors.grey,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'ID: ${donation.id}',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            donation.title,
            style: AppTheme.headingSmall.copyWith(fontSize: 16),
          ),
          const SizedBox(height: AppTheme.spacingXS),
          Text(
            'By ${donation.donorName} • ${donation.categoryDisplayName} • ${donation.conditionDisplayName}',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            donation.description,
            style: AppTheme.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsTab() {
    return RefreshIndicator(
      onRefresh: _loadRequests,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        itemCount: _requests.length,
        itemBuilder: (context, index) {
          final request = _requests[index];
          return _buildRequestCard(request);
        },
      ),
    );
  }

  Widget _buildRequestCard(DonationRequest request) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        boxShadow: AppTheme.shadowMD,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingS,
                  vertical: AppTheme.spacingXS,
                ),
                decoration: BoxDecoration(
                  color: request.statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusS),
                ),
                child: Text(
                  request.statusDisplayName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: request.statusColor,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'ID: ${request.id}',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            'Donation #${request.donationId}',
            style: AppTheme.headingSmall.copyWith(fontSize: 16),
          ),
          const SizedBox(height: AppTheme.spacingXS),
          Text(
            '${request.receiverName} → ${request.donorName}',
            style: AppTheme.bodyMedium,
          ),
          const SizedBox(height: AppTheme.spacingXS),
          Text(
            _formatDate(request.createdAt),
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
          ),
          if (request.message != null && request.message!.isNotEmpty) ...[
            const SizedBox(height: AppTheme.spacingS),
            Text(
              '"${request.message}"',
              style: AppTheme.bodyMedium.copyWith(
                fontStyle: FontStyle.italic,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'donor':
        return Colors.green;
      case 'receiver':
        return Colors.blue;
      case 'admin':
        return Colors.purple;
      default:
        return AppTheme.textSecondaryColor;
    }
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return '${date.day}/${date.month}/${date.year}';
  }
}
