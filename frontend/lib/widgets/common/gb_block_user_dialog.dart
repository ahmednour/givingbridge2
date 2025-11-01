import 'package:flutter/material.dart';
import '../../core/theme/design_system.dart';
import '../../services/api_service.dart';
import 'gb_button.dart';
import 'gb_text_field.dart';

class GBBlockUserDialog extends StatefulWidget {
  final int userId;
  final String userName;
  final VoidCallback? onBlocked;

  const GBBlockUserDialog({
    Key? key,
    required this.userId,
    required this.userName,
    this.onBlocked,
  }) : super(key: key);

  @override
  State<GBBlockUserDialog> createState() => _GBBlockUserDialogState();

  static Future<bool?> show({
    required BuildContext context,
    required int userId,
    required String userName,
    VoidCallback? onBlocked,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => GBBlockUserDialog(
        userId: userId,
        userName: userName,
        onBlocked: onBlocked,
      ),
    );
  }
}

class _GBBlockUserDialogState extends State<GBBlockUserDialog> {
  final _reasonController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _handleBlock() async {
    setState(() => _isLoading = true);

    final response = await ApiService.blockUser(
      widget.userId.toString(),
      reason: _reasonController.text.trim().isEmpty
          ? null
          : _reasonController.text.trim(),
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (response.success) {
      widget.onBlocked?.call();
      Navigator.of(context).pop(true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.userName} has been blocked'),
          backgroundColor: DesignSystem.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.error ?? 'Failed to block user'),
          backgroundColor: DesignSystem.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? DesignSystem.neutral900 : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: DesignSystem.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.block,
                      color: DesignSystem.error,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Block User',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? DesignSystem.neutral100
                                : DesignSystem.neutral900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.userName,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? DesignSystem.neutral400
                                : DesignSystem.neutral600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    icon: Icon(
                      Icons.close,
                      color: isDark
                          ? DesignSystem.neutral400
                          : DesignSystem.neutral600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Warning message
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: DesignSystem.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: DesignSystem.warning.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: DesignSystem.warning,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Blocking this user will prevent them from contacting you and viewing your donations.',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? DesignSystem.neutral200
                              : DesignSystem.neutral800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Reason field (optional)
              GBTextField(
                controller: _reasonController,
                label: 'Reason (Optional)',
                hint: 'Why are you blocking this user?',
                maxLines: 3,
                enabled: !_isLoading,
              ),

              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: GBButton(
                      text: 'Cancel',
                      variant: GBButtonVariant.secondary,
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.of(context).pop(false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GBButton(
                      text: 'Block User',
                      variant: GBButtonVariant.danger,
                      isLoading: _isLoading,
                      onPressed: _isLoading ? null : _handleBlock,
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
