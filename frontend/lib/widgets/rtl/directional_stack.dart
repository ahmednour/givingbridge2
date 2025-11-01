import 'package:flutter/material.dart';
import '../../services/rtl_layout_service.dart';

/// A Stack widget that automatically adapts to RTL layouts
/// Provides proper directional positioning for Arabic and other RTL languages
class DirectionalStack extends StatelessWidget {
  const DirectionalStack({
    super.key,
    this.alignment = AlignmentDirectional.topStart,
    this.textDirection,
    this.fit = StackFit.loose,
    this.clipBehavior = Clip.hardEdge,
    this.children = const <Widget>[],
  });

  final AlignmentGeometry alignment;
  final TextDirection? textDirection;
  final StackFit fit;
  final Clip clipBehavior;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final isRTL = RTLLayoutService.isRTL(context);
    
    // Convert alignment to RTL if it's an Alignment (not AlignmentDirectional)
    AlignmentGeometry directionalAlignment = alignment;
    if (alignment is Alignment) {
      directionalAlignment = RTLLayoutService.convertAlignmentToRTL(
        alignment as Alignment,
        isRTL,
      );
    }

    return Stack(
      alignment: directionalAlignment,
      textDirection: textDirection ?? RTLLayoutService.getTextDirection(context),
      fit: fit,
      clipBehavior: clipBehavior,
      children: children,
    );
  }
}

/// A Positioned widget that automatically adapts to RTL layouts
/// Provides proper directional positioning within DirectionalStack
class DirectionalPositioned extends StatelessWidget {
  const DirectionalPositioned({
    super.key,
    this.left,
    this.top,
    this.right,
    this.bottom,
    this.width,
    this.height,
    required this.child,
  });

  DirectionalPositioned.fromRect({
    super.key,
    required Rect rect,
    required this.child,
  })  : left = rect.left,
        top = rect.top,
        width = rect.width,
        height = rect.height,
        right = null,
        bottom = null;

  DirectionalPositioned.fromRelativeRect({
    super.key,
    required RelativeRect rect,
    required this.child,
  })  : left = rect.left,
        top = rect.top,
        right = rect.right,
        bottom = rect.bottom,
        width = null,
        height = null;

  const DirectionalPositioned.fill({
    super.key,
    this.left = 0.0,
    this.top = 0.0,
    this.right = 0.0,
    this.bottom = 0.0,
    required this.child,
  })  : width = null,
        height = null;

  const DirectionalPositioned.directional({
    super.key,
    required TextDirection textDirection,
    double? start,
    double? top,
    double? end,
    double? bottom,
    double? width,
    double? height,
    required this.child,
  })  : left = textDirection == TextDirection.ltr ? start : end,
        right = textDirection == TextDirection.ltr ? end : start,
        top = top,
        bottom = bottom,
        width = width,
        height = height;

  final double? left;
  final double? top;
  final double? right;
  final double? bottom;
  final double? width;
  final double? height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isRTL = RTLLayoutService.isRTL(context);
    
    // Swap left and right positions for RTL
    double? directionalLeft = left;
    double? directionalRight = right;
    
    if (isRTL && (left != null || right != null)) {
      directionalLeft = right;
      directionalRight = left;
    }

    return Positioned(
      left: directionalLeft,
      top: top,
      right: directionalRight,
      bottom: bottom,
      width: width,
      height: height,
      child: child,
    );
  }
}