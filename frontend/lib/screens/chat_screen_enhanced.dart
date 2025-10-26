import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../core/theme/design_system.dart';
import '../core/utils/rtl_utils.dart';
import '../widgets/common/gb_button.dart';
import '../widgets/common/gb_empty_state.dart';
import '../widgets/common/gb_block_user_dialog.dart';
import '../widgets/common/gb_report_user_dialog.dart';
import '../widgets/common/gb_user_avatar.dart';
import '../widgets/dialogs/conversation_info_dialog.dart';
import '../providers/auth_provider.dart';
import '../providers/message_provider.dart';
import '../services/socket_service.dart';
import '../models/chat_message.dart';
import '../models/user.dart';
import '../l10n/app_localizations.dart';

class ChatScreenEnhanced extends StatefulWidget {
  final String otherUserId;
  final String otherUserName;
  final String? otherUserAvatarUrl;
  final String? donationId;
  final String? requestId;
  final String? conversationId;

  const ChatScreenEnhanced({
    Key? key,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserAvatarUrl,
    this.donationId,
    this.requestId,
    this.conversationId,
  }) : super(key: key);

  @override
  State<ChatScreenEnhanced> createState() => _ChatScreenEnhancedState();
}

class _ChatScreenEnhancedState extends State<ChatScreenEnhanced>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();

  late AnimationController _typingAnimationController;
  late AnimationController _messageAnimationController;
  late Animation<double> _typingAnimation;
  late Animation<double> _messageAnimation;

  Timer? _typingTimer;
  Timer? _scrollTimer;
  bool _isTyping = false;
  bool _isUserTyping = false;
  bool _showScrollToBottom = false;

  @override
  void initState() {
    super.initState();

    _initializeAnimations();
    _initializeChat();
    _setupScrollListener();
    _setupTypingListener();
  }

  void _initializeAnimations() {
    _typingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _messageAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _typingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _typingAnimationController,
      curve: Curves.easeInOut,
    ));

    _messageAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _messageAnimationController,
      curve: Curves.easeOut,
    ));

    _messageAnimationController.forward();
  }

  void _initializeChat() {
    final messageProvider =
        Provider.of<MessageProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Set authenticated user ID
    if (authProvider.user?.id != null) {
      messageProvider.setAuthenticatedUserId(authProvider.user!.id.toString());
    }

    // Load messages for this conversation
    messageProvider.loadMessages(widget.conversationId ?? widget.otherUserId);

    // Mark conversation as read
    messageProvider.markConversationAsRead(widget.otherUserId);

    // Join conversation room for real-time updates
    SocketService().joinConversation(
      widget.conversationId ?? widget.otherUserId,
    );

    // Listen for new messages
    SocketService().onNewMessage = (message) {
      if ((message.conversationId != null &&
              message.conversationId == widget.conversationId) ||
          (message.senderId == widget.otherUserId ||
              message.receiverId == widget.otherUserId)) {
        messageProvider.addNewMessage(message);
        _scrollToBottom();

        // Auto-mark as read if conversation is open
        if (message.senderId.toString() == widget.otherUserId) {
          Future.delayed(const Duration(milliseconds: 500), () {
            messageProvider.markMessageAsRead(message.id.toString());
          });
        }
      }
    };

    // Listen for message sent confirmation (to replace optimistic message)
    SocketService().onMessageSent = (message) {
      // The message provider will handle duplicates, so we can just add the confirmed message
      messageProvider.addNewMessage(message);
    };

    // Listen for typing indicators
    SocketService().onUserTyping = (userId, isTyping) {
      if (userId == widget.otherUserId) {
        setState(() {
          _isUserTyping = isTyping;
        });

        if (_isUserTyping) {
          _typingAnimationController.repeat();
        } else {
          _typingAnimationController.stop();
        }
      }
    };

    // Listen for message read status
    SocketService().onMessageRead = (messageId) {
      messageProvider.markMessageAsRead(messageId.toString());
    };
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      final isAtBottom = _scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100;

      setState(() {
        _showScrollToBottom = !isAtBottom;
      });
    });
  }

  void _setupTypingListener() {
    _messageController.addListener(() {
      final text = _messageController.text.trim();

      if (text.isNotEmpty && !_isTyping) {
        setState(() {
          _isTyping = true;
        });
        _sendTypingIndicator(true);

        _typingTimer?.cancel();
        _typingTimer = Timer(const Duration(seconds: 2), () {
          setState(() {
            _isTyping = false;
          });
          _sendTypingIndicator(false);
        });
      } else if (text.isEmpty && _isTyping) {
        setState(() {
          _isTyping = false;
        });
        _sendTypingIndicator(false);
        _typingTimer?.cancel();
      } else {
        // Update UI when text changes to enable/disable send button
        setState(() {});
      }
    });
  }

  void _sendTypingIndicator(bool isTyping) {
    SocketService().sendTyping(widget.conversationId ?? widget.otherUserId);
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    final messageProvider =
        Provider.of<MessageProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Create optimistic message with negative ID to distinguish it from real messages
    final optimisticMessage = ChatMessage(
      id: -DateTime.now().millisecondsSinceEpoch, // Negative temporary ID
      senderId: authProvider.user?.id ?? 0,
      senderName: authProvider.user?.name ?? 'You',
      receiverId: int.parse(widget.otherUserId),
      receiverName: widget.otherUserName,
      donationId:
          widget.donationId != null ? int.parse(widget.donationId!) : null,
      requestId: widget.requestId != null ? int.parse(widget.requestId!) : null,
      content: content,
      isRead: false,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );

    // Add optimistic message
    messageProvider.addNewMessage(optimisticMessage);
    _messageController.clear();
    _scrollToBottom();

    // Send message via socket
    try {
      SocketService().sendMessage(
        receiverId: widget.otherUserId,
        content: content,
        donationId: widget.donationId,
        requestId: widget.requestId,
      );
    } catch (e) {
      // Remove optimistic message on error
      messageProvider.deleteMessage(optimisticMessage.id.toString());
      _showErrorSnackbar('Failed to send message: ${e.toString()}');
    }
  }

  void _scrollToBottom() {
    _scrollTimer?.cancel();
    _scrollTimer = Timer(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: DesignSystem.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showLoadingSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: DesignSystem.primaryBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _typingAnimationController.dispose();
    _messageAnimationController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    _messageFocusNode.dispose();
    _typingTimer?.cancel();
    _scrollTimer?.cancel();

    // Leave conversation room
    SocketService().leaveConversation(
      widget.conversationId ?? widget.otherUserId,
    );

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.getBackgroundColor(context),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: Consumer<MessageProvider>(
              builder: (context, messageProvider, child) {
                final messages = messageProvider.getMessagesByUserId(
                  widget.conversationId ?? widget.otherUserId,
                );

                if (messageProvider.isLoading) {
                  return _buildLoadingState();
                }

                if (messages.isEmpty) {
                  return _buildEmptyState();
                }

                return Stack(
                  children: [
                    // Messages List
                    ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length + (_isUserTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == messages.length && _isUserTyping) {
                          return _buildTypingIndicator();
                        }

                        final message = messages[index];
                        return _buildMessageBubble(message, index);
                      },
                    ),

                    // Scroll to Bottom Button
                    if (_showScrollToBottom)
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: FloatingActionButton.small(
                          onPressed: _scrollToBottom,
                          backgroundColor: DesignSystem.primaryBlue,
                          child: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),

          // Typing Indicator
          if (_isUserTyping) _buildTypingIndicator(),

          // Message Input
          _buildMessageInput(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppBar(
      backgroundColor: DesignSystem.getSurfaceColor(context),
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          RTLUtils.getDirectionalIcon(context, Icons.arrow_back,
              start: Icons.arrow_back, end: Icons.arrow_forward),
          color: isDark ? DesignSystem.neutral200 : DesignSystem.neutral900,
        ),
        onPressed: () => Navigator.pop(context, true),
      ),
      title: Row(
        children: [
          // Avatar
          GBUserAvatar(
            avatarUrl: widget.otherUserAvatarUrl,
            userName: widget.otherUserName,
            size: 40,
          ),

          const SizedBox(width: 16),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.otherUserName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? DesignSystem.neutral200
                            : DesignSystem.neutral900,
                      ),
                ),
                if (widget.donationId != null || widget.requestId != null)
                  Text(
                    widget.donationId != null
                        ? 'Donation #${widget.donationId}'
                        : '${l10n.request} #${widget.requestId}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: DesignSystem.primaryBlue,
                        ),
                  ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // More Options
        PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert,
            color: isDark ? DesignSystem.neutral200 : DesignSystem.neutral900,
          ),
          onSelected: (value) {
            switch (value) {
              case 'info':
                _showConversationInfo();
                break;
              case 'block':
                _showBlockConfirmation();
                break;
              case 'report':
                _showReportDialog();
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'info',
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 20),
                  const SizedBox(width: 12),
                  const Text('Conversation Info'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'block',
              child: Row(
                children: [
                  Icon(Icons.block, size: 20, color: DesignSystem.error),
                  const SizedBox(width: 12),
                  Text(AppLocalizations.of(context)!.blockUser,
                      style: TextStyle(color: DesignSystem.error)),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'report',
              child: Row(
                children: [
                  Icon(Icons.report, size: 20, color: DesignSystem.warning),
                  const SizedBox(width: 12),
                  Text(AppLocalizations.of(context)!.reportUser,
                      style: TextStyle(color: DesignSystem.warning)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(DesignSystem.primaryBlue),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading messages...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: DesignSystem.neutral600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;
    return GBEmptyState(
      icon: Icons.chat_bubble_outline,
      title: l10n.messages,
      message: 'Send message to ${widget.otherUserName}',
    );
  }

  Widget _buildMessageBubble(ChatMessage message, int index) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isFromCurrentUser =
        message.senderId.toString() == authProvider.user?.id;

    return AnimatedBuilder(
      animation: _messageAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _messageAnimation.value,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: isFromCurrentUser
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: [
                if (!isFromCurrentUser) ...[
                  _buildSenderAvatar(message),
                  const SizedBox(width: 12),
                ],
                Flexible(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isFromCurrentUser
                          ? DesignSystem.primaryBlue
                          : Colors.white,
                      borderRadius: RTLUtils.getBorderRadius(
                        context,
                        topStart: 18,
                        topEnd: 18,
                        bottomStart: isFromCurrentUser ? 18 : 4,
                        bottomEnd: isFromCurrentUser ? 4 : 18,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Message Content
                        if (message.messageType == 'image' &&
                            message.attachmentUrl != null)
                          _buildImageMessage(message, isFromCurrentUser)
                        else
                          Text(
                            message.content,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: isFromCurrentUser
                                      ? Colors.white
                                      : DesignSystem.neutral900,
                                  height: 1.3,
                                ),
                          ),

                        const SizedBox(height: 8),

                        // Message Info
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _formatMessageTime(message.createdAt),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: isFromCurrentUser
                                        ? Colors.white.withOpacity(0.7)
                                        : DesignSystem.neutral600,
                                    fontSize: 11,
                                  ),
                            ),
                            if (isFromCurrentUser) ...[
                              const SizedBox(width: 8),
                              Icon(
                                message.isRead ? Icons.done_all : Icons.done,
                                size: 14,
                                color: message.isRead
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.7),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (isFromCurrentUser) ...[
                  const SizedBox(width: 12),
                  _buildSenderAvatar(message),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSenderAvatar(ChatMessage message) {
    return GBUserAvatar(
      avatarUrl: widget.otherUserAvatarUrl,
      userName: message.senderName,
      size: 32,
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          _buildSenderAvatar(ChatMessage(
            id: 0,
            senderId: int.parse(widget.otherUserId),
            senderName: widget.otherUserName,
            receiverId: 0,
            receiverName: '',
            content: '',
            isRead: false,
            createdAt: '',
            updatedAt: '',
          )),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: AnimatedBuilder(
              animation: _typingAnimation,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Typing...',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: DesignSystem.neutral600,
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(3, (index) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: DesignSystem.primaryBlue,
                              shape: BoxShape.circle,
                            ),
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                          );
                        }),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: DesignSystem.getSurfaceColor(context),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: 12 + MediaQuery.of(context).padding.bottom,
      ),
      child: Row(
        children: [
          // Attachment Button
          IconButton(
            onPressed: _showAttachmentOptions,
            icon: Icon(
              Icons.attach_file,
              color: DesignSystem.neutral600,
            ),
          ),

          // Message Input Field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color:
                    isDark ? DesignSystem.neutral800 : DesignSystem.neutral100,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                    color: isDark
                        ? DesignSystem.neutral700
                        : DesignSystem.neutral300),
              ),
              child: TextField(
                controller: _messageController,
                focusNode: _messageFocusNode,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: l10n.message,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Send Button
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _messageController.text.trim().isNotEmpty
                  ? DesignSystem.primaryBlue
                  : DesignSystem.neutral300,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _messageController.text.trim().isNotEmpty
                    ? _sendMessage
                    : null,
                borderRadius: BorderRadius.circular(24),
                child: const Icon(
                  Icons.send,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Attach File',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GBButton(
                    text: 'Camera',
                    variant: GBButtonVariant.secondary,
                    leftIcon: const Icon(Icons.camera_alt, size: 20),
                    onPressed: () {
                      Navigator.pop(context);
                      _takePhoto();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GBButton(
                    text: 'Gallery',
                    variant: GBButtonVariant.secondary,
                    leftIcon: const Icon(Icons.photo_library, size: 20),
                    onPressed: () {
                      Navigator.pop(context);
                      _pickImage();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        await _sendImageMessage(image);
      }
    } catch (e) {
      _showErrorSnackbar('Failed to pick image: ${e.toString()}');
    }
  }

  void _takePhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        await _sendImageMessage(image);
      }
    } catch (e) {
      _showErrorSnackbar('Failed to take photo: ${e.toString()}');
    }
  }

  Future<void> _sendImageMessage(XFile imageFile) async {
    try {
      // Show loading indicator
      _showLoadingSnackbar('Sending image...');

      // Convert XFile to File
      final File imageFileObj = File(imageFile.path);

      // Get file size
      final int fileSizeInBytes = await imageFileObj.length();
      final double fileSizeInMB = fileSizeInBytes / (1024 * 1024);

      // Check file size limit (5MB)
      if (fileSizeInMB > 5.0) {
        _showErrorSnackbar('Image size must be less than 5MB');
        return;
      }

      // Upload image to server
      final messageProvider =
          Provider.of<MessageProvider>(context, listen: false);

      final uploadResponse = await messageProvider.uploadImage(imageFileObj);

      if (uploadResponse == null || !uploadResponse.success) {
        _showErrorSnackbar(
            'Failed to upload image: ${uploadResponse?.error ?? "Unknown error"}');
        return;
      }

      // Get the uploaded image URL and other info
      final imageUrl = uploadResponse.data?['url'] as String?;
      final fileName = uploadResponse.data?['originalName'] as String?;
      final fileSize = uploadResponse.data?['size'] as int?;

      if (imageUrl == null) {
        _showErrorSnackbar('Failed to get uploaded image URL');
        return;
      }

      // Create a ChatMessage object for the image
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final imageMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch, // Temporary ID
        senderId: authProvider.user?.id ?? 0,
        senderName: authProvider.user?.name ?? 'You',
        receiverId: int.parse(widget.otherUserId),
        receiverName: widget.otherUserName,
        donationId:
            widget.donationId != null ? int.parse(widget.donationId!) : null,
        requestId:
            widget.requestId != null ? int.parse(widget.requestId!) : null,
        content: '📷 Image',
        isRead: false,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        messageType: 'image',
        attachmentUrl: imageUrl,
        attachmentName: fileName,
        attachmentSize: fileSize,
      );

      // Add optimistic message
      messageProvider.addNewMessage(imageMessage);

      // Send message with image attachment
      final success = await messageProvider.sendMessage(
        receiverId: widget.otherUserId,
        content: '📷 Image',
        donationId: widget.donationId,
        requestId: widget.requestId,
        messageType: 'image',
        attachmentUrl: imageUrl,
        attachmentName: fileName,
        attachmentSize: fileSize,
      );

      if (!success) {
        _showErrorSnackbar('Failed to send image message');
        return;
      }

      // Clear loading
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image sent successfully'),
          backgroundColor: DesignSystem.success,
        ),
      );
    } catch (e) {
      _showErrorSnackbar('Failed to send image: ${e.toString()}');
    }
  }

  Widget _buildImageMessage(ChatMessage message, bool isFromCurrentUser) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRemoteImage = message.attachmentUrl != null &&
        (message.attachmentUrl!.startsWith('http://') ||
            message.attachmentUrl!.startsWith('https://'));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image preview
        GestureDetector(
          onTap: () => _showImagePreview(message.attachmentUrl!),
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 200,
              maxHeight: 200,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isFromCurrentUser
                    ? Colors.white.withOpacity(0.3)
                    : (isDark
                        ? DesignSystem.neutral700
                        : DesignSystem.neutral300),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: isRemoteImage
                  ? Image.network(
                      message.attachmentUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 100,
                          color: DesignSystem.neutral300,
                          child: const Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                            size: 40,
                          ),
                        );
                      },
                    )
                  : Image.file(
                      File(message.attachmentUrl!),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 100,
                          color: DesignSystem.neutral300,
                          child: const Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                            size: 40,
                          ),
                        );
                      },
                    ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Image info
        Text(
          message.content,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isFromCurrentUser
                    ? Colors.white.withOpacity(0.8)
                    : DesignSystem.neutral600,
                fontSize: 12,
              ),
        ),
      ],
    );
  }

  void _showImagePreview(String imagePath) {
    final isRemoteImage =
        imagePath.startsWith('http://') || imagePath.startsWith('https://');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              // Full screen image
              Center(
                child: InteractiveViewer(
                  child: isRemoteImage
                      ? Image.network(
                          imagePath,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 300,
                              height: 300,
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                                size: 60,
                              ),
                            );
                          },
                        )
                      : Image.file(
                          File(imagePath),
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 300,
                              height: 300,
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                                size: 60,
                              ),
                            );
                          },
                        ),
                ),
              ),

              // Close button
              Positioned(
                top: 40,
                right: 20,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 30,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.5),
                    shape: const CircleBorder(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showConversationInfo() async {
    final messageProvider =
        Provider.of<MessageProvider>(context, listen: false);
    final messages = messageProvider.messages;
    final firstMessage = messages.isNotEmpty ? messages.first : null;

    // Create User object for the other user
    final otherUser = User(
      id: int.parse(widget.otherUserId),
      name: widget.otherUserName,
      email: '',
      role: 'donor',
      avatarUrl: widget.otherUserAvatarUrl,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );

    await showDialog(
      context: context,
      builder: (context) => ConversationInfoDialog(
        otherUser: otherUser,
        messageCount: messages.length,
        firstMessageDate: firstMessage != null
            ? DateTime.tryParse(firstMessage['createdAt'] ?? '')
            : null,
        onArchive: () {
          _archiveConversation();
        },
        onBlock: () {
          _showBlockConfirmation();
        },
        onReport: () {
          _showReportDialog();
        },
      ),
    );
  }

  Future<void> _archiveConversation() async {
    final messageProvider =
        Provider.of<MessageProvider>(context, listen: false);
    final success = await messageProvider.archiveConversation(
      int.parse(widget.otherUserId),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conversation archived'),
          backgroundColor: DesignSystem.success,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  void _showBlockConfirmation() {
    GBBlockUserDialog.show(
      context: context,
      userId: int.parse(widget.otherUserId),
      userName: widget.otherUserName,
      onBlocked: () {
        // Navigate back after blocking
        Navigator.of(context).pop();
      },
    );
  }

  void _showReportDialog() {
    GBReportUserDialog.show(
      context: context,
      userId: int.parse(widget.otherUserId),
      userName: widget.otherUserName,
    );
  }

  String _formatMessageTime(String dateString) {
    final date = DateTime.parse(dateString);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${date.day}/${date.month} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
  }
}
