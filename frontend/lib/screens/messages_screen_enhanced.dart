import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme_enhanced.dart';
import '../core/constants/ui_constants.dart';
import '../widgets/app_components.dart';
import '../providers/message_provider.dart';
import '../providers/auth_provider.dart';
import '../models/conversation.dart';
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
      backgroundColor: AppTheme.backgroundColor,
      appBar: _buildAppBar(),
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
                    if (messageProvider.isLoading) {
                      return _buildLoadingState();
                    }

                    final conversations = _filterConversations(
                      messageProvider.conversations.cast<Conversation>(),
                    );

                    if (conversations.isEmpty) {
                      return _buildEmptyState();
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        await messageProvider.loadConversations();
                      },
                      child: ListView.builder(
                        padding: EdgeInsets.all(UIConstants.spacingM),
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
        backgroundColor: AppTheme.primaryColor,
        child: Icon(
          Icons.edit,
          color: Colors.white,
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final l10n = AppLocalizations.of(context)!;

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(
        l10n.messages,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.textPrimaryColor,
              fontWeight: FontWeight.w600,
            ),
      ),
      centerTitle: true,
      actions: [
        // Mark All as Read
        Consumer<MessageProvider>(
          builder: (context, messageProvider, child) {
            if (messageProvider.unreadCount > 0) {
              return IconButton(
                onPressed: () => messageProvider.loadUnreadCount(),
                icon: Icon(
                  Icons.done_all,
                  color: AppTheme.primaryColor,
                ),
                tooltip: l10n.markAllAsRead,
              );
            }
            return const SizedBox.shrink();
          },
        ),

        // More Options
        PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert,
            color: AppTheme.textPrimaryColor,
          ),
          onSelected: (value) {
            switch (value) {
              case 'settings':
                _showMessageSettings();
                break;
              case 'archived':
                _showArchivedConversations();
                break;
              case 'blocked':
                _showBlockedUsers();
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings, size: 20),
                  AppSpacing.horizontal(UIConstants.spacingS),
                  Text(l10n.messageSettings),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'archived',
              child: Row(
                children: [
                  Icon(Icons.archive, size: 20),
                  AppSpacing.horizontal(UIConstants.spacingS),
                  Text(l10n.archivedConversations),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'blocked',
              child: Row(
                children: [
                  Icon(Icons.block, size: 20),
                  AppSpacing.horizontal(UIConstants.spacingS),
                  Text(l10n.blockedUsers),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchAndFilterBar() {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(UIConstants.spacingM),
      child: Column(
        children: [
          // Search Bar
          AppTextField(
            hint: l10n.searchMessages,
            prefixIcon: Icon(Icons.search),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),

          AppSpacing.vertical(UIConstants.spacingM),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(l10n.all, 'all'),
                AppSpacing.horizontal(UIConstants.spacingS),
                _buildFilterChip(l10n.unread, 'unread'),
                AppSpacing.horizontal(UIConstants.spacingS),
                _buildFilterChip(l10n.donations, 'donations'),
                AppSpacing.horizontal(UIConstants.spacingS),
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

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: UIConstants.spacingM,
          vertical: UIConstants.spacingS,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(UIConstants.radiusM),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isSelected ? Colors.white : AppTheme.textPrimaryColor,
                fontWeight: FontWeight.w500,
              ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
          AppSpacing.vertical(UIConstants.spacingM),
          Text(
            AppLocalizations.of(context)!.loadingMessages,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              size: 40,
              color: AppTheme.primaryColor,
            ),
          ),
          AppSpacing.vertical(UIConstants.spacingL),
          Text(
            l10n.noMessages,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          AppSpacing.vertical(UIConstants.spacingS),
          Text(
            l10n.noMessagesDescription,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
            textAlign: TextAlign.center,
          ),
          AppSpacing.vertical(UIConstants.spacingL),
          AppButton(
            text: l10n.startConversation,
            icon: Icons.add,
            onPressed: _startNewConversation,
          ),
        ],
      ),
    );
  }

  Widget _buildConversationItem(Conversation conversation) {
    final l10n = AppLocalizations.of(context)!;

    return AppCard(
      margin: EdgeInsets.only(bottom: UIConstants.spacingS),
      onTap: () => _openConversation(conversation),
      child: Row(
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Text(
                    conversation.displayTitle.isNotEmpty
                        ? conversation.displayTitle[0].toUpperCase()
                        : 'U',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                ),
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
                      color: AppTheme.errorColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        conversation.unreadCount > 9
                            ? '9+'
                            : conversation.unreadCount.toString(),
                        style: TextStyle(
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

          AppSpacing.horizontal(UIConstants.spacingM),

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
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: conversation.hasUnreadMessages
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: conversation.hasUnreadMessages
                                  ? AppTheme.textPrimaryColor
                                  : AppTheme.textPrimaryColor,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      conversation.timeAgo,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                    ),
                  ],
                ),

                AppSpacing.vertical(UIConstants.spacingXS),

                // Last Message and Status
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        conversation.lastMessageContent ?? l10n.noMessages,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: conversation.hasUnreadMessages
                                  ? AppTheme.textPrimaryColor
                                  : AppTheme.textSecondaryColor,
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
                              Provider.of<AuthProvider>(context, listen: false)
                                  .user
                                  ?.id)
                            Icon(
                              Icons.done_all,
                              size: 16,
                              color: AppTheme.textSecondaryColor,
                            ),
                        ],
                      ),
                  ],
                ),

                // Context Info (Donation/Request)
                if (conversation.isDonationRelated ||
                    conversation.isRequestRelated)
                  Padding(
                    padding: EdgeInsets.only(top: UIConstants.spacingXS),
                    child: Row(
                      children: [
                        Icon(
                          conversation.isDonationRelated
                              ? Icons.card_giftcard
                              : Icons.request_page,
                          size: 12,
                          color: AppTheme.primaryColor,
                        ),
                        AppSpacing.horizontal(UIConstants.spacingXS),
                        Text(
                          conversation.isDonationRelated
                              ? '${l10n.aboutDonation} #${conversation.donationId}'
                              : '${l10n.aboutRequest} #${conversation.requestId}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.primaryColor,
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
          donationId: conversation.donationId,
          requestId: conversation.requestId,
        ),
      ),
    );
  }

  void _startNewConversation() {
    // TODO: Implement new conversation flow
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.newConversationComingSoon),
        backgroundColor: AppTheme.infoColor,
      ),
    );
  }

  void _showMessageSettings() {
    // TODO: Implement message settings
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.messageSettingsComingSoon),
        backgroundColor: AppTheme.infoColor,
      ),
    );
  }

  void _showArchivedConversations() {
    // TODO: Implement archived conversations
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(AppLocalizations.of(context)!.archivedConversationsComingSoon),
        backgroundColor: AppTheme.infoColor,
      ),
    );
  }

  void _showBlockedUsers() {
    // TODO: Implement blocked users
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.blockedUsersComingSoon),
        backgroundColor: AppTheme.infoColor,
      ),
    );
  }
}
