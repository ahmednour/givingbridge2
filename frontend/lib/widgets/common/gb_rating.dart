import 'package:flutter/material.dart';
import '../../core/theme/design_system.dart';

/// Star Rating Component for GivingBridge
///
/// A flexible rating widget that supports:
/// - Display mode (read-only with optional average)
/// - Input mode (interactive for user ratings)
/// - Half-star precision
/// - Customizable size and colors
/// - Tap and drag gestures
class GBRating extends StatefulWidget {
  /// The current rating value (0.0 to 5.0)
  final double rating;

  /// Callback when rating changes (null = read-only mode)
  final ValueChanged<double>? onRatingChanged;

  /// Number of stars to display
  final int starCount;

  /// Size of each star
  final double size;

  /// Color for filled stars
  final Color? filledColor;

  /// Color for empty stars
  final Color? emptyColor;

  /// Allow half-star ratings
  final bool allowHalfRating;

  /// Show rating number next to stars
  final bool showRatingNumber;

  /// Show total count (e.g., "4.5 (123 reviews)")
  final int? totalReviews;

  /// Spacing between stars
  final double spacing;

  const GBRating({
    Key? key,
    required this.rating,
    this.onRatingChanged,
    this.starCount = 5,
    this.size = 24,
    this.filledColor,
    this.emptyColor,
    this.allowHalfRating = true,
    this.showRatingNumber = false,
    this.totalReviews,
    this.spacing = 4,
  }) : super(key: key);

  @override
  State<GBRating> createState() => _GBRatingState();
}

class _GBRatingState extends State<GBRating> {
  late double _currentRating;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.rating;
  }

  @override
  void didUpdateWidget(GBRating oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.rating != oldWidget.rating) {
      _currentRating = widget.rating;
    }
  }

  void _updateRating(double newRating) {
    if (widget.onRatingChanged != null) {
      setState(() {
        _currentRating = newRating.clamp(0.0, widget.starCount.toDouble());
      });
      widget.onRatingChanged!(_currentRating);
    }
  }

  double _calculateRating(Offset localPosition, double starWidth) {
    final starIndex = (localPosition.dx / (starWidth + widget.spacing)).floor();
    final positionInStar =
        (localPosition.dx % (starWidth + widget.spacing)) / starWidth;

    double rating;
    if (widget.allowHalfRating) {
      rating = starIndex + (positionInStar > 0.5 ? 1.0 : 0.5);
    } else {
      rating = starIndex + (positionInStar > 0.5 ? 1.0 : 0.0);
    }

    return rating.clamp(0.0, widget.starCount.toDouble());
  }

  @override
  Widget build(BuildContext context) {
    final isInteractive = widget.onRatingChanged != null;
    final filledColor = widget.filledColor ?? DesignSystem.warning;
    final emptyColor = widget.emptyColor ?? DesignSystem.neutral300;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Star rating display/input
        GestureDetector(
          onTapDown: isInteractive
              ? (details) {
                  final RenderBox box = context.findRenderObject() as RenderBox;
                  final localPosition =
                      box.globalToLocal(details.globalPosition);
                  _updateRating(_calculateRating(localPosition, widget.size));
                }
              : null,
          onPanUpdate: isInteractive
              ? (details) {
                  final RenderBox box = context.findRenderObject() as RenderBox;
                  final localPosition =
                      box.globalToLocal(details.globalPosition);
                  _updateRating(_calculateRating(localPosition, widget.size));
                }
              : null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              widget.starCount,
              (index) => Padding(
                padding: EdgeInsets.only(
                  right: index < widget.starCount - 1 ? widget.spacing : 0,
                ),
                child: _buildStar(index, filledColor, emptyColor),
              ),
            ),
          ),
        ),

        // Rating number and review count
        if (widget.showRatingNumber || widget.totalReviews != null) ...[
          const SizedBox(width: 8),
          Text(
            _buildRatingText(),
            style: DesignSystem.bodyMedium(context).copyWith(
              color: DesignSystem.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStar(int index, Color filledColor, Color emptyColor) {
    final starValue = index + 1.0;
    final fillPercentage = (_currentRating - index).clamp(0.0, 1.0);

    if (fillPercentage == 0.0) {
      // Empty star
      return Icon(
        Icons.star_border,
        size: widget.size,
        color: emptyColor,
      );
    } else if (fillPercentage == 1.0) {
      // Full star
      return Icon(
        Icons.star,
        size: widget.size,
        color: filledColor,
      );
    } else {
      // Partial star (half-filled)
      return Stack(
        children: [
          Icon(
            Icons.star_border,
            size: widget.size,
            color: emptyColor,
          ),
          ClipRect(
            clipper: _StarClipper(fillPercentage),
            child: Icon(
              Icons.star,
              size: widget.size,
              color: filledColor,
            ),
          ),
        ],
      );
    }
  }

  String _buildRatingText() {
    final ratingStr = _currentRating.toStringAsFixed(1);
    if (widget.totalReviews != null && widget.totalReviews! > 0) {
      return '$ratingStr (${widget.totalReviews} reviews)';
    } else if (widget.showRatingNumber) {
      return ratingStr;
    }
    return '';
  }
}

/// Custom clipper for half-star effect
class _StarClipper extends CustomClipper<Rect> {
  final double fillPercentage;

  _StarClipper(this.fillPercentage);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0, 0, size.width * fillPercentage, size.height);
  }

  @override
  bool shouldReclip(_StarClipper oldClipper) {
    return oldClipper.fillPercentage != fillPercentage;
  }
}

/// Compact rating display with icon and text
class GBCompactRating extends StatelessWidget {
  final double rating;
  final int? totalReviews;
  final double iconSize;
  final Color? color;

  const GBCompactRating({
    Key? key,
    required this.rating,
    this.totalReviews,
    this.iconSize = 16,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final displayColor = color ?? DesignSystem.warning;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.star,
          size: iconSize,
          color: displayColor,
        ),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: DesignSystem.bodySmall(context).copyWith(
            fontWeight: FontWeight.w600,
            color: DesignSystem.textPrimary,
          ),
        ),
        if (totalReviews != null && totalReviews! > 0) ...[
          Text(
            ' ($totalReviews)',
            style: DesignSystem.bodySmall(context).copyWith(
              color: DesignSystem.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

/// Usage Examples:
/// 
/// // Read-only display
/// GBRating(
///   rating: 4.5,
///   showRatingNumber: true,
///   totalReviews: 123,
/// )
/// 
/// // Interactive input
/// GBRating(
///   rating: _userRating,
///   onRatingChanged: (newRating) {
///     setState(() => _userRating = newRating);
///   },
///   size: 32,
/// )
/// 
/// // Compact display
/// GBCompactRating(
///   rating: 4.8,
///   totalReviews: 45,
/// )
