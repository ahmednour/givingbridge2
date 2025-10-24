import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/design_system.dart';
import '../models/blocked_user.dart';
import '../services/api_service.dart';
import '../widgets/common/gb_button.dart';
import '../widgets/common/gb_empty_state.dart';

class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({Key? key}) : super(key: key);

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  List<BlockedUser> _blockedUsers = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBlockedUsers();
  }

  Future<void> _loadBlockedUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await ApiService.getBlockedUsers();

    if (!mounted) return;

    if (response.success) {
      setState(() {
        _blockedUsers = response.data ?? [];
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = response.error;
        _isLoading = false;
      });
    }
  }

  Future<void> _unblockUser(BlockedUser blockedUser) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _UnblockConfirmationDialog(
        userName: blockedUser.blockedUserInfo?.name ?? 'this user',
      ),
    );

    if (confirmed != true) return;

    final response = await ApiService.unblockUser(blockedUser.blockedId);

    if (!mounted) return;

    if (response.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${blockedUser.blockedUserInfo?.name ?? 'User'} has been unblocked'),
          backgroundColor: DesignSystem.success,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Refresh list
      _loadBlockedUsers();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.error ?? 'Failed to unblock user'),
          backgroundColor: DesignSystem.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? DesignSystem.neutral900 : DesignSystem.neutral100,
      appBar: AppBar(
        backgroundColor: isDark ? DesignSystem.neutral900 : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? DesignSystem.neutral100 : DesignSystem.neutral900,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Blocked Users',
          style: TextStyle(
            color: isDark ? DesignSystem.neutral100 : DesignSystem.neutral900,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: Icon(
                Icons.refresh,
                color:
                    isDark ? DesignSystem.neutral100 : DesignSystem.neutral900,
              ),
              onPressed: _loadBlockedUsers,
              tooltip: 'Refresh',
            ),
        ],
      ),
      body: _buildBody(isDark),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                DesignSystem.primaryBlue,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading blocked users...',
              style: TextStyle(
                color:
                    isDark ? DesignSystem.neutral400 : DesignSystem.neutral600,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: DesignSystem.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load blocked users',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? DesignSystem.neutral100
                      : DesignSystem.neutral900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark
                      ? DesignSystem.neutral400
                      : DesignSystem.neutral600,
                ),
              ),
              const SizedBox(height: 24),
              GBButton(
                text: 'Try Again',
                variant: GBButtonVariant.primary,
                onPressed: _loadBlockedUsers,
              ),
            ],
          ),
        ),
      );
    }

    if (_blockedUsers.isEmpty) {
      return GBEmptyState(
        icon: Icons.block,
        title: 'No Blocked Users',
        message: 'You haven\'t blocked anyone yet.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBlockedUsers,
      color: DesignSystem.primaryBlue,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _blockedUsers.length,
        itemBuilder: (context, index) {
          final blockedUser = _blockedUsers[index];
          return _BlockedUserCard(
            blockedUser: blockedUser,
            isDark: isDark,
            onUnblock: () => _unblockUser(blockedUser),
          )
              .animate()
              .fadeIn(
                duration: const Duration(milliseconds: 300),
                delay: Duration(milliseconds: 50 * index),
              )
              .slideX(
                begin: 0.2,
                end: 0,
                duration: const Duration(milliseconds: 300),
                delay: Duration(milliseconds: 50 * index),
              );
        },
      ),
    );
  }
}

class _BlockedUserCard extends StatelessWidget {
  final BlockedUser blockedUser;
  final bool isDark;
  final VoidCallback onUnblock;

  const _BlockedUserCard({
    Key? key,
    required this.blockedUser,
    required this.isDark,
    required this.onUnblock,
  }) : super(key: key);

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year${difference.inDays >= 730 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month${difference.inDays >= 60 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final userInfo = blockedUser.blockedUserInfo;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? DesignSystem.neutral800 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? DesignSystem.neutral700 : DesignSystem.neutral200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: DesignSystem.primaryBlue.withOpacity(0.1),
                backgroundImage: userInfo?.avatarUrl != null
                    ? NetworkImage(userInfo!.avatarUrl!)
                    : null,
                child: userInfo?.avatarUrl == null
                    ? Text(
                        userInfo?.name.substring(0, 1).toUpperCase() ?? '?',
                        style: TextStyle(
                          color: DesignSystem.primaryBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),

              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userInfo?.name ?? 'Unknown User',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? DesignSystem.neutral100
                            : DesignSystem.neutral900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Blocked ${_formatDate(blockedUser.createdAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? DesignSystem.neutral500
                            : DesignSystem.neutral600,
                      ),
                    ),
                  ],
                ),
              ),

              // Unblock button
              GBButton(
                text: 'Unblock',
                variant: GBButtonVariant.secondary,
                onPressed: onUnblock,
                size: GBButtonSize.small,
              ),
            ],
          ),

          // Reason (if provided)
          if (blockedUser.reason != null && blockedUser.reason!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    isDark ? DesignSystem.neutral900 : DesignSystem.neutral100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: isDark
                        ? DesignSystem.neutral500
                        : DesignSystem.neutral600,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      blockedUser.reason!,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? DesignSystem.neutral400
                            : DesignSystem.neutral700,
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
  }
}

class _UnblockConfirmationDialog extends StatelessWidget {
  final String userName;

  const _UnblockConfirmationDialog({
    Key? key,
    required this.userName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? DesignSystem.neutral900 : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: DesignSystem.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.check_circle_outline,
                  color: DesignSystem.primaryBlue,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Unblock User?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? DesignSystem.neutral100
                      : DesignSystem.neutral900,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to unblock $userName? They will be able to contact you and view your donations again.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? DesignSystem.neutral400
                      : DesignSystem.neutral600,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GBButton(
                      text: 'Cancel',
                      variant: GBButtonVariant.secondary,
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GBButton(
                      text: 'Unblock',
                      variant: GBButtonVariant.primary,
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
