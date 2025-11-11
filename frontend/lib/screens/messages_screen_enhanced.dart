import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/design_system.dart';
import '../widgets/common/web_card.dart';
import '../widgets/common/gb_text_field.dart';
import '../widgets/common/gb_empty_state.dart';
import '../widgets/common/gb_user_avatar.dart';
import '../widgets/common/gb_skeleton_widgets.dart';
import '../widgets/dialogs/start_conversation_dialog.dart';
import '../providers/message_provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart' show Conversation;
import '../models/user.dart';
import '../screens/chat_screen_enhanced.dart';
import '../l10n/app_localizations.dart';

class MessagesScreenEnhanced extends StatefulWidget {
  const MessagesScreenEnhanced({Key? key}) : super(key: key);

  @override
  State<MessagesScreenEnhanced> createState() => _MessagesScreenEnhancedState();
}

class _MessagesScreenEnhancedState extends State<MessagesScreenEnhanced>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String _searchQuery = '';
  String _selectedFilter = 'all'; // 'all', 'unread', 'donations', 'requests'

  @override
  void initState() {
    super.initState();

    _initializeAnimations();
    _loadConversations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  void _loadConversations() {
    final messageProvider =
        Provider.of<MessageProvider>(context, listen: false);
    messageProvider.loadConversations();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.getBackgroundColor(context),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              // Search and Filter Bar
              _buildSearchAndFilterBar(),

              // Conversations List
              Expanded(
                child: Consumer<MessageProvider>(
                  builder: (context, messageProvider, child) {
                    if (messageProvider.isLoadingConversations &&
                        messageProvider.conversations.isEmpty) {
                      return const GBConversationListSkeleton();
                    }

                    // Convert dynamic list to Conversation objects
                    final conversationsList = messageProvider.conversations
                        .map((c) =>
                            c is Conversation ? c : Conversation.fromJson(c))
                        .toList();
                    final conversations =
                        _filterConversations(conversationsList);

                    if (conversations.isEmpty) {
                      return _buildEmptyState();
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        await messageProvider.loadConversations();
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: conversations.length,
                        itemBuilder: (context, index) {
                          final conversation = conversations[index];
                          return _buildConversationItem(conversation);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startNewConversation,
        backgroundColor: DesignSystem.primaryBlue,
        child: const Icon(
          Icons.edit,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSearchAndFilterBar() {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      color: DesignSystem.getSurfaceColor(context),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search Bar
          GBTextField(
            label: l10n.searchMessages,
            prefixIcon: const Icon(Icons.search),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),

          const SizedBox(height: 16),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(l10n.all, 'all'),
                const SizedBox(width: 12),
                _buildFilterChip(l10n.unread, 'unread'),
                const SizedBox(width: 12),
                _buildFilterChip(l10n.donations, 'donations'),
                const SizedBox(width: 12),
                _buildFilterChip(l10n.requests, 'requests'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? DesignSystem.primaryBlue
              : (isDark ? DesignSystem.neutral800 : DesignSystem.neutral100),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? DesignSystem.primaryBlue
                : (isDark ? DesignSystem.neutral700 : DesignSystem.neutral300),
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isSelected
                    ? Colors.white
                    : (isDark
                        ? DesignSystem.neutral200
                        : DesignSystem.neutral900),
                fontWeight: FontWeight.w500,
              ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GBEmptyState(
            icon: Icons.chat_bubble_outline,
            title: l10n.noMessages,
            message: l10n.noMessagesDescription,
            actionLabel: l10n.startConversation,
            onAction: _startNewConversation,
          ),
        ],
      ),
    );
  }

  Widget _buildConversationItem(Conversation conversation) {
    final l10n = AppLocalizations.of(context)!;

    return Dismissible(
      key: Key(conversation.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: DesignSystem.warning,
          borderRadius: BorderRadius.circular(DesignSystem.radiusM),
        ),
        child: const Icon(
          Icons.archive_outlined,
          color: Colors.white,
          size: 28,
        ),
      ),
      confirmDismiss: (direction) async {
        return await _showArchiveConfirmation(conversation);
      },
      onDismissed: (direction) {
        _archiveConversation(conversation);
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: WebCard(
          onTap: () => _openConversation(conversation),
          child: Row(
            children: [
              // Avatar
              Stack(
                children: [
                  GBUserAvatar(
                    avatarUrl: conversation.avatarUrl,
                    userName: conversation.displayTitle,
                    size: 50,
                  ),

                  // Unread Badge
                  if (conversation.hasUnreadMessages)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: DesignSystem.error,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            conversation.unreadCount > 9
                                ? '9+'
                                : conversation.unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
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
                            conversation.displayTitle,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: conversation.hasUnreadMessages
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          conversation.timeAgo,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: DesignSystem.neutral600,
                                  ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Last Message and Status
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conversation.lastMessageContent?.toString() ??
                                l10n.noMessages,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: conversation.hasUnreadMessages
                                          ? DesignSystem.neutral900
                                          : DesignSystem.neutral600,
                                      fontWeight: conversation.hasUnreadMessages
                                          ? FontWeight.w500
                                          : FontWeight.normal,
                                    ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),

                        // Message Status Icons
                        if (conversation.lastMessageSenderId != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (conversation.lastMessageSenderId ==
                                  Provider.of<AuthProvider>(context,
                                          listen: false)
                                      .user
                                      ?.id)
                                Icon(
                                  Icons.done_all,
                                  size: 16,
                                  color: DesignSystem.neutral600,
                                ),
                            ],
                          ),
                      ],
                    ),

                    // Context Info (Donation/Request)
                    if (conversation.isDonationRelated ||
                        conversation.isRequestRelated)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Icon(
                              conversation.isDonationRelated
                                  ? Icons.card_giftcard
                                  : Icons.request_page,
                              size: 12,
                              color: DesignSystem.primaryBlue,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              conversation.isDonationRelated
                                  ? '${l10n.aboutDonation} #${conversation.donationId}'
                                  : '${l10n.aboutRequest} #${conversation.requestId}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: DesignSystem.primaryBlue,
                                    fontSize: 11,
                                  ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Conversation> _filterConversations(List<Conversation> conversations) {
    List<Conversation> filtered = conversations;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((conversation) {
        return conversation.displayTitle
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            (conversation.lastMessageContent
                    ?.toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ??
                false);
      }).toList();
    }

    // Apply category filter
    switch (_selectedFilter) {
      case 'unread':
        filtered = filtered
            .where((conversation) => conversation.hasUnreadMessages)
            .toList();
        break;
      case 'donations':
        filtered = filtered
            .where((conversation) => conversation.isDonationRelated)
            .toList();
        break;
      case 'requests':
        filtered = filtered
            .where((conversation) => conversation.isRequestRelated)
            .toList();
        break;
      case 'all':
      default:
        // No additional filtering
        break;
    }

    // Sort by last message time
    filtered.sort((a, b) {
      final aTime = a.lastMessageDateTime ?? a.updatedAtDateTime;
      final bTime = b.lastMessageDateTime ?? b.updatedAtDateTime;
      return bTime.compareTo(aTime);
    });

    return filtered;
  }

  void _openConversation(Conversation conversation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreenEnhanced(
          otherUserId: conversation.otherParticipantId,
          otherUserName: conversation.otherParticipantName,
          conversationId: conversation.id,
          donationId: conversation.donationId?.toString(),
          requestId: conversation.requestId?.toString(),
        ),
      ),
    );
  }

  Future<void> _startNewConversation() async {
    final selectedUser = await showDialog<User>(
      context: context,
      builder: (context) => const StartConversationDialog(),
    );

    if (selectedUser != null && mounted) {
      final messageProvider =
          Provider.of<MessageProvider>(context, listen: false);
      final success = await messageProvider.startConversation(
        selectedUser.id,
        selectedUser.name,
      );

      if (success && mounted) {
        // Navigate to chat screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreenEnhanced(
              otherUserId: selectedUser.id.toString(),
              otherUserName: selectedUser.name,
            ),
          ),
        );
      }
    }
  }

  Future<bool> _showArchiveConfirmation(Conversation conversation) async {
    final l10n = AppLocalizations.of(context)!;
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignSystem.radiusM),
            ),
            title: Text(l10n.archiveConversation),
            content: Text(
                l10n.archiveConversationConfirm(conversation.displayTitle)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: DesignSystem.warning,
                ),
                child: Text(l10n.archive),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _archiveConversation(Conversation conversation) async {
    final messageProvider =
        Provider.of<MessageProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;
    final success = await messageProvider.archiveConversation(
      int.parse(conversation.otherParticipantId),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.conversationArchived),
          backgroundColor: DesignSystem.success,
          action: SnackBarAction(
            label: 'Undo',
            textColor: Colors.white,
            onPressed: () {
              messageProvider.unarchiveConversation(
                  int.parse(conversation.otherParticipantId));
            },
          ),
        ),
      );
    }
  }
}
