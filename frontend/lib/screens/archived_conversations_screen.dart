import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/design_system.dart';
import '../widgets/common/web_card.dart';
import '../widgets/common/gb_empty_state.dart';
import '../widgets/common/gb_user_avatar.dart';
import '../providers/message_provider.dart';
import '../screens/chat_screen_enhanced.dart';
import '../l10n/app_localizations.dart';

class ArchivedConversationsScreen extends StatefulWidget {
  const ArchivedConversationsScreen({Key? key}) : super(key: key);

  @override
  State<ArchivedConversationsScreen> createState() =>
      _ArchivedConversationsScreenState();
}

class _ArchivedConversationsScreenState
    extends State<ArchivedConversationsScreen> {
  List<dynamic> _archivedConversations = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadArchivedConversations();
  }

  Future<void> _loadArchivedConversations() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final messageProvider =
          Provider.of<MessageProvider>(context, listen: false);
      final archivedConversations =
          await messageProvider.loadArchivedConversations();

      if (mounted) {
        setState(() {
          _archivedConversations = archivedConversations;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load archived conversations: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  void _openConversation(dynamic conversation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreenEnhanced(
          otherUserId: conversation['userId'].toString(),
          otherUserName: conversation['userName'],
          otherUserAvatarUrl: conversation['userAvatarUrl'],
        ),
      ),
    );
  }

  Future<void> _unarchiveConversation(dynamic conversation) async {
    final messageProvider =
        Provider.of<MessageProvider>(context, listen: false);
    final success = await messageProvider.unarchiveConversation(
      conversation['userId'],
    );

    if (success && mounted) {
      // Remove from archived list
      setState(() {
        _archivedConversations
            .removeWhere((c) => c['userId'] == conversation['userId']);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.conversationUnarchived),
          backgroundColor: DesignSystem.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: DesignSystem.getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: DesignSystem.getSurfaceColor(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? DesignSystem.neutral200 : DesignSystem.neutral900,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.archivedConversations,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color:
                    isDark ? DesignSystem.neutral200 : DesignSystem.neutral900,
                fontWeight: FontWeight.w600,
              ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _error != null
              ? Center(
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
                        _error!,
                        style: const TextStyle(
                          color: DesignSystem.error,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadArchivedConversations,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DesignSystem.primaryBlue,
                        ),
                        child: Text(l10n.retry),
                      ),
                    ],
                  ),
                )
              : _archivedConversations.isEmpty
                  ? Center(
                      child: GBEmptyState(
                        icon: Icons.archive_outlined,
                        title: l10n.noMessages,
                        message: l10n.noMessagesDescription,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _archivedConversations.length,
                      itemBuilder: (context, index) {
                        final conversation = _archivedConversations[index];
                        return _buildConversationItem(conversation);
                      },
                    ),
    );
  }

  Widget _buildConversationItem(dynamic conversation) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: WebCard(
        onTap: () => _openConversation(conversation),
        child: Row(
          children: [
            // Avatar
            GBUserAvatar(
              avatarUrl: conversation['userAvatarUrl'],
              userName: conversation['userName'],
              size: 50,
            ),

            const SizedBox(width: 16),

            // Conversation Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          conversation['userName'],
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (conversation['lastMessage'] != null)
                        Text(
                          _formatTimeAgo(
                              conversation['lastMessage']['createdAt']),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: DesignSystem.neutral600,
                                  ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Last Message
                  if (conversation['lastMessage'] != null)
                    Text(
                      conversation['lastMessage']['content'],
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: DesignSystem.neutral600,
                            overflow: TextOverflow.ellipsis,
                          ),
                      maxLines: 1,
                    ),

                  const SizedBox(height: 8),

                  // Unarchive button
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => _unarchiveConversation(conversation),
                      icon: const Icon(
                        Icons.unarchive_outlined,
                        size: 16,
                      ),
                      label: Text(AppLocalizations.of(context)!.unarchive),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(String dateString) {
    final date = DateTime.parse(dateString);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
