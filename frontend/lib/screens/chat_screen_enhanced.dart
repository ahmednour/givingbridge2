import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../core/theme/app_theme_enhanced.dart';
import '../core/utils/rtl_utils.dart';
import '../core/constants/ui_constants.dart';
import '../widgets/common/gb_button.dart';
import '../widgets/app_components.dart';
import '../providers/auth_provider.dart';
import '../providers/message_provider.dart';
import '../services/socket_service.dart';
import '../models/chat_message.dart';
import '../l10n/app_localizations.dart';

class ChatScreenEnhanced extends StatefulWidget {
  final String otherUserId;
  final String otherUserName;
  final String? donationId;
  final String? requestId;
  final String? conversationId;

  const ChatScreenEnhanced({
    Key? key,
    required this.otherUserId,
    required this.otherUserName,
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

    // Load messages for this conversation
    messageProvider.loadMessages(widget.conversationId ?? widget.otherUserId);

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
      }
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
        _isTyping = true;
        _sendTypingIndicator(true);

        _typingTimer?.cancel();
        _typingTimer = Timer(const Duration(seconds: 2), () {
          _isTyping = false;
          _sendTypingIndicator(false);
        });
      } else if (text.isEmpty && _isTyping) {
        _isTyping = false;
        _sendTypingIndicator(false);
        _typingTimer?.cancel();
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

    // Create optimistic message
    final optimisticMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch, // Temporary ID
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
            AppSpacing.horizontal(UIConstants.spacingS),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UIConstants.radiusM),
        ),
        margin: EdgeInsets.all(UIConstants.spacingM),
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
            AppSpacing.horizontal(UIConstants.spacingS),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UIConstants.radiusM),
        ),
        margin: EdgeInsets.all(UIConstants.spacingM),
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
      backgroundColor: AppTheme.backgroundColor,
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
                      padding: EdgeInsets.all(UIConstants.spacingM),
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
                        bottom: UIConstants.spacingM,
                        right: UIConstants.spacingM,
                        child: FloatingActionButton.small(
                          onPressed: _scrollToBottom,
                          backgroundColor: AppTheme.primaryColor,
                          child: Icon(
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
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          RTLUtils.getDirectionalIcon(context, Icons.arrow_back,
              start: Icons.arrow_back, end: Icons.arrow_forward),
          color: AppTheme.textPrimaryColor,
        ),
        onPressed: () => Navigator.pop(context, true),
      ),
      title: Row(
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                widget.otherUserName.isNotEmpty
                    ? widget.otherUserName[0].toUpperCase()
                    : 'U',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),

          AppSpacing.horizontal(UIConstants.spacingM),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.otherUserName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimaryColor,
                      ),
                ),
                if (widget.donationId != null || widget.requestId != null)
                  Text(
                    widget.donationId != null
                        ? 'Donation #${widget.donationId}'
                        : '${l10n.request} #${widget.requestId}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.primaryColor,
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
            color: AppTheme.textPrimaryColor,
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
                  Icon(Icons.info_outline, size: 20),
                  AppSpacing.horizontal(UIConstants.spacingS),
                  Text(l10n.messages),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'block',
              child: Row(
                children: [
                  Icon(Icons.block, size: 20, color: AppTheme.errorColor),
                  AppSpacing.horizontal(UIConstants.spacingS),
                  Text(AppLocalizations.of(context)!.blockUser,
                      style: TextStyle(color: AppTheme.errorColor)),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'report',
              child: Row(
                children: [
                  Icon(Icons.report, size: 20, color: AppTheme.warningColor),
                  AppSpacing.horizontal(UIConstants.spacingS),
                  Text(AppLocalizations.of(context)!.reportUser,
                      style: TextStyle(color: AppTheme.warningColor)),
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
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
          AppSpacing.vertical(UIConstants.spacingM),
          Text(
            'Loading messages...',
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
            l10n.messages,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          AppSpacing.vertical(UIConstants.spacingS),
          Text(
            'Send message to ${widget.otherUserName}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
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
            margin: EdgeInsets.only(bottom: UIConstants.spacingS),
            child: Row(
              mainAxisAlignment: isFromCurrentUser
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: [
                if (!isFromCurrentUser) ...[
                  _buildSenderAvatar(message),
                  AppSpacing.horizontal(UIConstants.spacingS),
                ],
                Flexible(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: UIConstants.spacingM,
                      vertical: UIConstants.spacingS,
                    ),
                    decoration: BoxDecoration(
                      color: isFromCurrentUser
                          ? AppTheme.primaryColor
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
                                      : AppTheme.textPrimaryColor,
                                  height: 1.3,
                                ),
                          ),

                        AppSpacing.vertical(UIConstants.spacingXS),

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
                                        : AppTheme.textSecondaryColor,
                                    fontSize: 11,
                                  ),
                            ),
                            if (isFromCurrentUser) ...[
                              AppSpacing.horizontal(UIConstants.spacingXS),
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
                  AppSpacing.horizontal(UIConstants.spacingS),
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
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          message.senderName.isNotEmpty
              ? message.senderName[0].toUpperCase()
              : 'U',
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: EdgeInsets.only(bottom: UIConstants.spacingS),
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
          AppSpacing.horizontal(UIConstants.spacingS),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: UIConstants.spacingM,
              vertical: UIConstants.spacingS,
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
                            color: AppTheme.textSecondaryColor,
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                    AppSpacing.horizontal(UIConstants.spacingXS),
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(3, (index) {
                          return AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            margin: EdgeInsets.symmetric(horizontal: 1),
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
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        left: UIConstants.spacingM,
        right: UIConstants.spacingM,
        top: UIConstants.spacingS,
        bottom: UIConstants.spacingS + MediaQuery.of(context).padding.bottom,
      ),
      child: Row(
        children: [
          // Attachment Button
          IconButton(
            onPressed: _showAttachmentOptions,
            icon: Icon(
              Icons.attach_file,
              color: AppTheme.textSecondaryColor,
            ),
          ),

          // Message Input Field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: TextField(
                controller: _messageController,
                focusNode: _messageFocusNode,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: l10n.message,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: UIConstants.spacingM,
                    vertical: UIConstants.spacingS,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),

          AppSpacing.horizontal(UIConstants.spacingS),

          // Send Button
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _messageController.text.trim().isNotEmpty
                  ? AppTheme.primaryColor
                  : AppTheme.borderColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _messageController.text.trim().isNotEmpty
                    ? _sendMessage
                    : null,
                borderRadius: BorderRadius.circular(24),
                child: Icon(
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(UIConstants.radiusL),
        ),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(UIConstants.spacingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Attach File',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            AppSpacing.vertical(UIConstants.spacingL),
            Row(
              children: [
                Expanded(
                  child: GBSecondaryButton(
                    text: 'Camera',
                    leftIcon: const Icon(Icons.camera_alt, size: 20),
                    onPressed: () {
                      Navigator.pop(context);
                      _takePhoto();
                    },
                  ),
                ),
                AppSpacing.horizontal(UIConstants.spacingM),
                Expanded(
                  child: GBSecondaryButton(
                    text: 'Gallery',
                    leftIcon: const Icon(Icons.photo_library, size: 20),
                    onPressed: () {
                      Navigator.pop(context);
                      _pickImage();
                    },
                  ),
                ),
              ],
            ),
            AppSpacing.vertical(UIConstants.spacingL),
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

      // Create message with image
      final messageProvider =
          Provider.of<MessageProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // For now, we'll send the image as a text message with file path
      // In a real implementation, you would upload the image to a server first
      // Note: We create a ChatMessage object for future use but currently send via MessageProvider
      final message = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch,
        senderId: int.parse(authProvider.user?.id.toString() ?? '0'),
        senderName: authProvider.user?.name ?? '',
        receiverId: int.parse(widget.otherUserId),
        receiverName: widget.otherUserName,
        content: '📷 Image: ${imageFile.name}',
        messageType: 'image',
        donationId:
            widget.donationId != null ? int.parse(widget.donationId!) : null,
        requestId:
            widget.requestId != null ? int.parse(widget.requestId!) : null,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        isRead: false,
        attachmentUrl: imageFile.path, // Store local path for now
        attachmentName: imageFile.name,
        attachmentSize: fileSizeInBytes,
      );

      // Send message via MessageProvider (current implementation)
      await messageProvider.sendMessage(
        receiverId: widget.otherUserId,
        content: '📷 Image: ${imageFile.name}',
        donationId: widget.donationId,
        requestId: widget.requestId,
      );

      // TODO: In future, integrate the ChatMessage object with the actual message sending
      // This will allow proper image handling and display

      // Clear loading
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    } catch (e) {
      _showErrorSnackbar('Failed to send image: ${e.toString()}');
    }
  }

  Widget _buildImageMessage(ChatMessage message, bool isFromCurrentUser) {
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
                    : AppTheme.borderColor,
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(message.attachmentUrl!),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 100,
                    color: Colors.grey[300],
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
                    : AppTheme.textSecondaryColor,
                fontSize: 12,
              ),
        ),
      ],
    );
  }

  void _showImagePreview(String imagePath) {
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
                  child: Image.file(
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

  void _showConversationInfo() {
    // TODO: Implement conversation info dialog
    _showErrorSnackbar('Conversation info coming soon');
  }

  void _showBlockConfirmation() {
    // TODO: Implement block confirmation dialog
    _showErrorSnackbar('Block functionality coming soon');
  }

  void _showReportDialog() {
    // TODO: Implement report dialog
    _showErrorSnackbar('Report functionality coming soon');
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
