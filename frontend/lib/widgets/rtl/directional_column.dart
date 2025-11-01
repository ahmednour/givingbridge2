import 'package:flutter/material.dart';
import '../../services/rtl_layout_service.dart';

/// A Column widget that automatically adapts to RTL layouts
/// Provides proper directional behavior for Arabic and other RTL languages
class DirectionalColumn extends StatelessWidget {
  const DirectionalColumn({
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
    
    // Get directional cross axis alignment (horizontal alignment in Column)
    final directionalCrossAxis = RTLLayoutService.convertCrossAxisAlignmentToRTL(
      crossAxisAlignment,
      isRTL,
    );

    return Column(
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: directionalCrossAxis,
      textDirection: textDirection ?? RTLLayoutService.getTextDirection(context),
      verticalDirection: verticalDirection,
      textBaseline: textBaseline,
      children: children,
    );
  }
}