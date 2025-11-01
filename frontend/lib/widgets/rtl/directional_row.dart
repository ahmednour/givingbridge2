import 'package:flutter/material.dart';
import '../../services/rtl_layout_service.dart';

/// A Row widget that automatically adapts to RTL layouts
/// Provides proper directional behavior for Arabic and other RTL languages
class DirectionalRow extends StatelessWidget {
  const DirectionalRow({
    super.key,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.textDirection,
    this.verticalDirection = VerticalDirection.down,
    this.textBaseline,
    this.children = const <Widget>[],
  });

  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;
  final CrossAxisAlignment crossAxisAlignment;
  final TextDirection? textDirection;
  final VerticalDirection verticalDirection;
  final TextBaseline? textBaseline;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final isRTL = RTLLayoutService.isRTL(context);
    
    // Get directional properties
    final directionalMainAxis = RTLLayoutService.convertMainAxisAlignmentToRTL(
      mainAxisAlignment,
      isRTL,
    );
    
    final directionalCrossAxis = RTLLayoutService.convertCrossAxisAlignmentToRTL(
      crossAxisAlignment,
      isRTL,
    );

    // Reverse children order for RTL if needed for specific layouts
    final directionalChildren = _shouldReverseChildren(mainAxisAlignment, isRTL)
        ? children.reversed.toList()
        : children;

    return Row(
      mainAxisAlignment: directionalMainAxis,
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: directionalCrossAxis,
      textDirection: textDirection ?? RTLLayoutService.getTextDirection(context),
      verticalDirection: verticalDirection,
      textBaseline: textBaseline,
      children: directionalChildren,
    );
  }

  /// Determine if children should be reversed based on alignment and RTL
  bool _shouldReverseChildren(MainAxisAlignment alignment, bool isRTL) {
    // Only reverse for specific alignments that benefit from it
    switch (alignment) {
      case MainAxisAlignment.start:
      case MainAxisAlignment.end:
        return isRTL;
      default:
        return false;
    }
  }
}