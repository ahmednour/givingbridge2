import 'package:flutter/material.dart';
import '../../core/theme/design_system.dart';
import '../../models/user_report.dart';
import '../../services/api_service.dart';
import 'gb_button.dart';
import 'gb_text_field.dart';

class GBReportUserDialog extends StatefulWidget {
  final int userId;
  final String userName;
  final VoidCallback? onReported;

  const GBReportUserDialog({
    Key? key,
    required this.userId,
    required this.userName,
    this.onReported,
  }) : super(key: key);

  @override
  State<GBReportUserDialog> createState() => _GBReportUserDialogState();

  static Future<bool?> show({
    required BuildContext context,
    required int userId,
    required String userName,
    VoidCallback? onReported,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => GBReportUserDialog(
        userId: userId,
        userName: userName,
        onReported: onReported,
      ),
    );
  }
}

class _GBReportUserDialogState extends State<GBReportUserDialog> {
  ReportReason? _selectedReason;
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleReport() async {
    if (_selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a reason for reporting'),
          backgroundColor: DesignSystem.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please provide a description'),
          backgroundColor: DesignSystem.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final response = await ApiService.reportUser(
      userId: widget.userId,
      reason: _selectedReason!,
      description: _descriptionController.text.trim(),
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (response.success) {
      widget.onReported?.call();
      Navigator.of(context).pop(true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Report submitted successfully'),
          backgroundColor: DesignSystem.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.error ?? 'Failed to submit report'),
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
        child: SingleChildScrollView(
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
                        Icons.flag,
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
                            'Report User',
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

                // Info message
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: DesignSystem.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: DesignSystem.info.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: DesignSystem.info,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Your report will be reviewed by our team. False reports may result in action against your account.',
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

                // Reason selection
                Text(
                  'Reason for reporting *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? DesignSystem.neutral200
                        : DesignSystem.neutral900,
                  ),
                ),
                const SizedBox(height: 12),

                ...ReportReason.values.map((reason) {
                  final isSelected = _selectedReason == reason;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: _isLoading
                          ? null
                          : () => setState(() => _selectedReason = reason),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? DesignSystem.primaryBlue.withOpacity(0.1)
                              : (isDark
                                  ? DesignSystem.neutral800
                                  : DesignSystem.neutral100),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? DesignSystem.primaryBlue
                                : (isDark
                                    ? DesignSystem.neutral700
                                    : DesignSystem.neutral200),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                              color: isSelected
                                  ? DesignSystem.primaryBlue
                                  : (isDark
                                      ? DesignSystem.neutral500
                                      : DesignSystem.neutral400),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                reason.displayName,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: isDark
                                      ? DesignSystem.neutral200
                                      : DesignSystem.neutral900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),

                const SizedBox(height: 24),

                // Description field
                GBTextField(
                  controller: _descriptionController,
                  label: 'Description *',
                  hint:
                      'Please provide details about why you are reporting this user',
                  maxLines: 4,
                  enabled: !_isLoading,
                  maxLength: 500,
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
                        text: 'Submit Report',
                        variant: GBButtonVariant.primary,
                        isLoading: _isLoading,
                        onPressed: _isLoading ? null : _handleReport,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
