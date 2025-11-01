import 'package:flutter/material.dart';

/// RTL Layout Service for comprehensive directional layout management
/// This service provides utilities for converting LTR layouts to RTL equivalents
/// and handling complex directional transformations
class RTLLayoutService {
  /// Convert EdgeInsets from LTR to RTL equivalent
  static EdgeInsets convertPaddingToRTL(EdgeInsets padding, bool isRTL) {
    if (!isRTL) return padding;
    
    return EdgeInsets.only(
      left: padding.right,
      right: padding.left,
      top: padding.top,
      bottom: padding.bottom,
    );
  }

  /// Get directional padding with context awareness
  static EdgeInsets getDirectionalPadding(
    BuildContext context,
    EdgeInsets padding,
  ) {
    final locale = Localizations.localeOf(context);
    final isRTL = locale.languageCode == 'ar';
    return convertPaddingToRTL(padding, isRTL);
  }

  /// Convert Alignment from LTR to RTL equivalent
  static Alignment convertAlignmentToRTL(Alignment alignment, bool isRTL) {
    if (!isRTL) return alignment;
    
    // Mirror horizontal alignment for RTL
    return Alignment(
      -alignment.x, // Flip horizontal alignment
      alignment.y,  // Keep vertical alignment
    );
  }

  /// Get directional alignment with context awareness
  static Alignment getDirectionalAlignment(
    BuildContext context,
    Alignment alignment,
  ) {
    final locale = Localizations.localeOf(context);
    final isRTL = locale.languageCode == 'ar';
    return convertAlignmentToRTL(alignment, isRTL);
  }

  /// Convert CrossAxisAlignment for RTL layouts
  static CrossAxisAlignment convertCrossAxisAlignmentToRTL(
    CrossAxisAlignment alignment,
    bool isRTL,
  ) {
    if (!isRTL) return alignment;
    
    switch (alignment) {
      case CrossAxisAlignment.start:
        return CrossAxisAlignment.end;
      case CrossAxisAlignment.end:
        return CrossAxisAlignment.start;
      default:
        return alignment;
    }
  }

  /// Get directional cross axis alignment with context awareness
  static CrossAxisAlignment getDirectionalCrossAxisAlignment(
    BuildContext context,
    CrossAxisAlignment alignment,
  ) {
    final locale = Localizations.localeOf(context);
    final isRTL = locale.languageCode == 'ar';
    return convertCrossAxisAlignmentToRTL(alignment, isRTL);
  }

  /// Convert MainAxisAlignment for RTL layouts
  static MainAxisAlignment convertMainAxisAlignmentToRTL(
    MainAxisAlignment alignment,
    bool isRTL,
  ) {
    if (!isRTL) return alignment;
    
    switch (alignment) {
      case MainAxisAlignment.start:
        return MainAxisAlignment.end;
      case MainAxisAlignment.end:
        return MainAxisAlignment.start;
      default:
        return alignment;
    }
  }

  /// Get directional main axis alignment with context awareness
  static MainAxisAlignment getDirectionalMainAxisAlignment(
    BuildContext context,
    MainAxisAlignment alignment,
  ) {
    final locale = Localizations.localeOf(context);
    final isRTL = locale.languageCode == 'ar';
    return convertMainAxisAlignmentToRTL(alignment, isRTL);
  }

  /// Convert BorderRadius for RTL layouts
  static BorderRadius convertBorderRadiusToRTL(
    BorderRadius borderRadius,
    bool isRTL,
  ) {
    if (!isRTL) return borderRadius;
    
    return BorderRadius.only(
      topLeft: borderRadius.topRight,
      topRight: borderRadius.topLeft,
      bottomLeft: borderRadius.bottomRight,
      bottomRight: borderRadius.bottomLeft,
    );
  }

  /// Get directional border radius with context awareness
  static BorderRadius getDirectionalBorderRadius(
    BuildContext context,
    BorderRadius borderRadius,
  ) {
    final locale = Localizations.localeOf(context);
    final isRTL = locale.languageCode == 'ar';
    return convertBorderRadiusToRTL(borderRadius, isRTL);
  }

  /// Convert Matrix4 transformation for RTL layouts
  static Matrix4 convertTransformToRTL(Matrix4 transform, bool isRTL) {
    if (!isRTL) return transform;
    
    // Create a horizontal flip transformation
    final flipMatrix = Matrix4.identity()..scale(-1.0, 1.0, 1.0);
    return flipMatrix * transform * flipMatrix;
  }

  /// Get directional transform with context awareness
  static Matrix4 getDirectionalTransform(
    BuildContext context,
    Matrix4 transform,
  ) {
    final locale = Localizations.localeOf(context);
    final isRTL = locale.languageCode == 'ar';
    return convertTransformToRTL(transform, isRTL);
  }

  /// Get directional offset for positioning
  static Offset getDirectionalOffset(
    BuildContext context,
    Offset offset,
  ) {
    final locale = Localizations.localeOf(context);
    final isRTL = locale.languageCode == 'ar';
    
    if (!isRTL) return offset;
    
    // Flip horizontal offset for RTL
    return Offset(-offset.dx, offset.dy);
  }

  /// Convert Axis for RTL layouts (useful for scrolling direction)
  static Axis convertAxisToRTL(Axis axis, bool isRTL) {
    // Axis doesn't need conversion for RTL, but this method
    // is provided for consistency and future extensibility
    return axis;
  }

  /// Get scroll physics that work well with RTL
  static ScrollPhysics getDirectionalScrollPhysics(
    BuildContext context, {
    ScrollPhysics? parent,
  }) {
    // Return appropriate scroll physics for RTL
    // Currently using default, but can be customized for RTL-specific behavior
    return parent ?? const ClampingScrollPhysics();
  }

  /// Helper method to determine if context is RTL
  static bool isRTL(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'ar';
  }

  /// Helper method to get text direction from context
  static TextDirection getTextDirection(BuildContext context) {
    return isRTL(context) ? TextDirection.rtl : TextDirection.ltr;
  }

  /// Wrap widget with proper directionality
  static Widget wrapWithDirectionality(BuildContext context, Widget child) {
    return Directionality(
      textDirection: getTextDirection(context),
      child: child,
    );
  }

  /// Get directional icon data based on context
  static IconData getDirectionalIcon(
    BuildContext context, {
    required IconData ltrIcon,
    required IconData rtlIcon,
  }) {
    return isRTL(context) ? rtlIcon : ltrIcon;
  }

  /// Convert list order for RTL (useful for horizontal lists)
  static List<T> convertListOrderForRTL<T>(List<T> list, bool isRTL) {
    if (!isRTL) return list;
    return list.reversed.toList();
  }

  /// Get directional list order with context awareness
  static List<T> getDirectionalListOrder<T>(
    BuildContext context,
    List<T> list,
  ) {
    final isRtl = isRTL(context);
    return convertListOrderForRTL(list, isRtl);
  }

  /// Get appropriate text align for RTL
  static TextAlign getDirectionalTextAlign(
    BuildContext context, {
    TextAlign? defaultAlign,
  }) {
    final isRtl = isRTL(context);
    
    if (defaultAlign != null) {
      switch (defaultAlign) {
        case TextAlign.left:
          return isRtl ? TextAlign.right : TextAlign.left;
        case TextAlign.right:
          return isRtl ? TextAlign.left : TextAlign.right;
        case TextAlign.start:
          return TextAlign.start; // Flutter handles this automatically
        case TextAlign.end:
          return TextAlign.end; // Flutter handles this automatically
        default:
          return defaultAlign;
      }
    }
    
    return isRtl ? TextAlign.right : TextAlign.left;
  }

  /// Get directional flex properties for Row/Column widgets
  static Map<String, dynamic> getDirectionalFlexProperties(
    BuildContext context, {
    MainAxisAlignment? mainAxisAlignment,
    CrossAxisAlignment? crossAxisAlignment,
    MainAxisSize? mainAxisSize,
  }) {
    final isRtl = isRTL(context);
    
    return {
      'mainAxisAlignment': mainAxisAlignment != null
          ? convertMainAxisAlignmentToRTL(mainAxisAlignment, isRtl)
          : MainAxisAlignment.start,
      'crossAxisAlignment': crossAxisAlignment != null
          ? convertCrossAxisAlignmentToRTL(crossAxisAlignment, isRtl)
          : CrossAxisAlignment.center,
      'mainAxisSize': mainAxisSize ?? MainAxisSize.max,
    };
  }
}