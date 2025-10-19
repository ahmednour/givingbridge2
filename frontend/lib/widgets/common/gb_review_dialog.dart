import 'package:flutter/material.dart';
import '../../core/theme/design_system.dart';
import 'gb_rating.dart';
import 'gb_button.dart';

/// Review Dialog Component for submitting ratings
///
/// A modal dialog that allows users to:
/// - Select a star rating
/// - Write a review comment
/// - Submit feedback
class GBReviewDialog extends StatefulWidget {
  /// Title of the dialog
  final String title;

  /// Subtitle/description
  final String? subtitle;

  /// Name of the person/item being reviewed
  final String revieweeName;

  /// Initial rating value
  final double initialRating;

  /// Require comment before submission
  final bool requireComment;

  /// Minimum comment length (if required)
  final int minCommentLength;

  /// Maximum comment length
  final int maxCommentLength;

  /// Callback when review is submitted
  final Function(double rating, String comment) onSubmit;

  const GBReviewDialog({
    Key? key,
    this.title = 'Rate Your Experience',
    this.subtitle,
    required this.revieweeName,
    this.initialRating = 0.0,
    this.requireComment = false,
    this.minCommentLength = 10,
    this.maxCommentLength = 500,
    required this.onSubmit,
  }) : super(key: key);

  /// Show the dialog and return result
  static Future<bool?> show({
    required BuildContext context,
    String title = 'Rate Your Experience',
    String? subtitle,
    required String revieweeName,
    double initialRating = 0.0,
    bool requireComment = false,
    int minCommentLength = 10,
    int maxCommentLength = 500,
    required Function(double rating, String comment) onSubmit,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => GBReviewDialog(
        title: title,
        subtitle: subtitle,
        revieweeName: revieweeName,
        initialRating: initialRating,
        requireComment: requireComment,
        minCommentLength: minCommentLength,
        maxCommentLength: maxCommentLength,
        onSubmit: onSubmit,
      ),
    );
  }

  @override
  State<GBReviewDialog> createState() => _GBReviewDialogState();
}

class _GBReviewDialogState extends State<GBReviewDialog> {
  late double _rating;
  final _commentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  String? _validateComment(String? value) {
    if (widget.requireComment && (value == null || value.trim().isEmpty)) {
      return 'Please share your experience';
    }
    if (widget.requireComment &&
        value!.trim().length < widget.minCommentLength) {
      return 'Comment must be at least ${widget.minCommentLength} characters';
    }
    return null;
  }

  Future<void> _handleSubmit() async {
    if (_rating == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 12),
              Text('Please select a star rating'),
            ],
          ),
          backgroundColor: DesignSystem.warning,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await widget.onSubmit(_rating, _commentController.text.trim());
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Failed to submit review: $e')),
              ],
            ),
            backgroundColor: DesignSystem.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignSystem.radiusXL),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(DesignSystem.spaceXL),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: DesignSystem.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                    ),
                    child: Icon(
                      Icons.star,
                      color: DesignSystem.warning,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: DesignSystem.spaceM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: DesignSystem.titleLarge(context).copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (widget.subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            widget.subtitle!,
                            style: DesignSystem.bodySmall(context).copyWith(
                              color: DesignSystem.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _isSubmitting
                        ? null
                        : () => Navigator.of(context).pop(false),
                  ),
                ],
              ),

              const SizedBox(height: DesignSystem.spaceXL),

              // Reviewee Name
              Text(
                'Rating for:',
                style: DesignSystem.bodySmall(context).copyWith(
                  color: DesignSystem.textSecondary,
                ),
              ),
              const SizedBox(height: DesignSystem.spaceS),
              Text(
                widget.revieweeName,
                style: DesignSystem.titleMedium(context).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: DesignSystem.spaceXL),

              // Star Rating
              Center(
                child: Column(
                  children: [
                    Text(
                      'How would you rate your experience?',
                      style: DesignSystem.bodyMedium(context).copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: DesignSystem.spaceM),
                    GBRating(
                      rating: _rating,
                      onRatingChanged: (newRating) {
                        setState(() => _rating = newRating);
                      },
                      size: 40,
                      spacing: 8,
                      allowHalfRating: false, // Whole stars only for reviews
                    ),
                    const SizedBox(height: DesignSystem.spaceM),
                    if (_rating > 0)
                      Text(
                        _getRatingLabel(_rating),
                        style: DesignSystem.titleSmall(context).copyWith(
                          color: DesignSystem.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: DesignSystem.spaceXL),

              // Comment Field
              TextFormField(
                controller: _commentController,
                decoration: InputDecoration(
                  labelText: widget.requireComment
                      ? 'Your review *'
                      : 'Your review (optional)',
                  hintText: 'Share your experience...',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                  ),
                  counterText:
                      '${_commentController.text.length}/${widget.maxCommentLength}',
                ),
                maxLines: 4,
                maxLength: widget.maxCommentLength,
                validator: _validateComment,
                enabled: !_isSubmitting,
              ),

              const SizedBox(height: DesignSystem.spaceXL),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: GBSecondaryButton(
                      text: 'Cancel',
                      onPressed: _isSubmitting
                          ? null
                          : () => Navigator.of(context).pop(false),
                    ),
                  ),
                  const SizedBox(width: DesignSystem.spaceM),
                  Expanded(
                    child: GBPrimaryButton(
                      text: 'Submit Review',
                      onPressed: _isSubmitting ? null : _handleSubmit,
                      isLoading: _isSubmitting,
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

  String _getRatingLabel(double rating) {
    if (rating >= 5.0) return 'Excellent! ⭐️';
    if (rating >= 4.0) return 'Great! 👍';
    if (rating >= 3.0) return 'Good 👌';
    if (rating >= 2.0) return 'Fair 😐';
    return 'Poor 😞';
  }
}

/// Usage Example:
/// 
/// final result = await GBReviewDialog.show(
///   context: context,
///   revieweeName: 'John Doe',
///   requireComment: true,
///   onSubmit: (rating, comment) async {
///     await ApiService.submitRating(
///       donorId: donorId,
///       rating: rating,
///       comment: comment,
///     );
///   },
/// );
/// 
/// if (result == true) {
///   print('Review submitted successfully');
/// }
