import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../core/theme/design_system.dart';

class ConversationInfoDialog extends StatelessWidget {
  final User otherUser;
  final int messageCount;
  final DateTime? firstMessageDate;
  final VoidCallback? onArchive;
  final VoidCallback? onBlock;
  final VoidCallback? onReport;

  const ConversationInfoDialog({
    Key? key,
    required this.otherUser,
    this.messageCount = 0,
    this.firstMessageDate,
    this.onArchive,
    this.onBlock,
    this.onReport,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignSystem.radiusL),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Conversation Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: DesignSystem.neutral900,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  color: DesignSystem.neutral600,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // User Avatar and Info
            CircleAvatar(
              radius: 48,
              backgroundColor: DesignSystem.primaryBlue.withOpacity(0.1),
              backgroundImage:
                  otherUser.avatarUrl != null && otherUser.avatarUrl!.isNotEmpty
                      ? NetworkImage(otherUser.avatarUrl!)
                      : null,
              child: otherUser.avatarUrl == null || otherUser.avatarUrl!.isEmpty
                  ? Text(
                      otherUser.name[0].toUpperCase(),
                      style: const TextStyle(
                        color: DesignSystem.primaryBlue,
                        fontWeight: FontWeight.w700,
                        fontSize: 32,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 16),

            // User Name
            Text(
              otherUser.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: DesignSystem.neutral900,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),

            // Role Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getRoleColor(otherUser.role).withOpacity(0.1),
                borderRadius: BorderRadius.circular(DesignSystem.radiusS),
              ),
              child: Text(
                _getRoleLabel(otherUser.role),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _getRoleColor(otherUser.role),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // User Details
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: DesignSystem.neutral100,
                borderRadius: BorderRadius.circular(DesignSystem.radiusM),
              ),
              child: Column(
                children: [
                  if (otherUser.email.isNotEmpty)
                    _buildInfoRow(
                      Icons.email_outlined,
                      'Email',
                      otherUser.email,
                    ),
                  if (otherUser.phone != null &&
                      otherUser.phone!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      Icons.phone_outlined,
                      'Phone',
                      otherUser.phone!,
                    ),
                  ],
                  if (otherUser.location != null &&
                      otherUser.location!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      Icons.location_on_outlined,
                      'Location',
                      otherUser.location!,
                    ),
                  ],
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.chat_outlined,
                    'Messages',
                    '$messageCount message${messageCount != 1 ? 's' : ''}',
                  ),
                  if (firstMessageDate != null) ...[
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      Icons.calendar_today_outlined,
                      'First message',
                      _formatDate(firstMessageDate!),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Column(
              children: [
                if (onArchive != null)
                  _buildActionButton(
                    icon: Icons.archive_outlined,
                    label: 'Archive Conversation',
                    color: DesignSystem.warning,
                    onTap: () {
                      Navigator.of(context).pop();
                      onArchive!();
                    },
                  ),
                if (onBlock != null) ...[
                  const SizedBox(height: 12),
                  _buildActionButton(
                    icon: Icons.block_outlined,
                    label: 'Block User',
                    color: DesignSystem.error,
                    onTap: () {
                      Navigator.of(context).pop();
                      onBlock!();
                    },
                  ),
                ],
                if (onReport != null) ...[
                  const SizedBox(height: 12),
                  _buildActionButton(
                    icon: Icons.flag_outlined,
                    label: 'Report User',
                    color: DesignSystem.accentPink,
                    onTap: () {
                      Navigator.of(context).pop();
                      onReport!();
                    },
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: DesignSystem.neutral600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: DesignSystem.neutral600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: DesignSystem.neutral900,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DesignSystem.radiusM),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(DesignSystem.radiusM),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'donor':
        return DesignSystem.primaryBlue;
      case 'receiver':
        return DesignSystem.secondaryGreen;
      case 'admin':
        return DesignSystem.accentPink;
      default:
        return DesignSystem.neutral600;
    }
  }

  String _getRoleLabel(String role) {
    switch (role.toLowerCase()) {
      case 'donor':
        return 'Donor';
      case 'receiver':
        return 'Receiver';
      case 'admin':
        return 'Admin';
      default:
        return role;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    }
  }
}
