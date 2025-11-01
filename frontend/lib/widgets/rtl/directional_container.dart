import 'package:flutter/material.dart';
import '../../services/rtl_layout_service.dart';

/// A Container widget that automatically adapts to RTL layouts
/// Provides proper directional padding, margins, and alignment for Arabic and other RTL languages
class DirectionalContainer extends StatelessWidget {
  const DirectionalContainer({
    super.key,
    this.alignment,
    this.padding,
    this.color,
    this.decoration,
    this.foregroundDecoration,
    this.width,
    this.height,
    this.constraints,
    this.margin,
    this.transform,
    this.transformAlignment,
    this.child,
    this.clipBehavior = Clip.none,
  });

  final AlignmentGeometry? alignment;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Decoration? decoration;
  final Decoration? foregroundDecoration;
  final double? width;
  final double? height;
  final BoxConstraints? constraints;
  final EdgeInsetsGeometry? margin;
  final Matrix4? transform;
  final AlignmentGeometry? transformAlignment;
  final Widget? child;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final isRTL = RTLLayoutService.isRTL(context);
    
    // Convert padding to RTL if provided
    EdgeInsetsGeometry? directionalPadding;
    if (padding != null) {
      if (padding is EdgeInsets) {
        directionalPadding = RTLLayoutService.convertPaddingToRTL(
          padding as EdgeInsets,
          isRTL,
        );
      } else {
        directionalPadding = padding;
      }
    }

    // Convert margin to RTL if provided
    EdgeInsetsGeometry? directionalMargin;
    if (margin != null) {
      if (margin is EdgeInsets) {
        directionalMargin = RTLLayoutService.convertPaddingToRTL(
          margin as EdgeInsets,
          isRTL,
        );
      } else {
        directionalMargin = margin;
      }
    }

    // Convert alignment to RTL if provided
    AlignmentGeometry? directionalAlignment;
    if (alignment != null && alignment is Alignment) {
      directionalAlignment = RTLLayoutService.convertAlignmentToRTL(
        alignment as Alignment,
        isRTL,
      );
    } else {
      directionalAlignment = alignment;
    }

    // Convert transform alignment to RTL if provided
    AlignmentGeometry? directionalTransformAlignment;
    if (transformAlignment != null && transformAlignment is Alignment) {
      directionalTransformAlignment = RTLLayoutService.convertAlignmentToRTL(
        transformAlignment as Alignment,
        isRTL,
      );
    } else {
      directionalTransformAlignment = transformAlignment;
    }

    // Convert transform matrix to RTL if provided
    Matrix4? directionalTransform;
    if (transform != null) {
      directionalTransform = RTLLayoutService.convertTransformToRTL(
        transform!,
        isRTL,
      );
    }

    // Convert decoration border radius if it's a BoxDecoration
    Decoration? directionalDecoration = decoration;
    if (decoration is BoxDecoration && decoration != null) {
      final boxDecoration = decoration as BoxDecoration;
      if (boxDecoration.borderRadius != null && boxDecoration.borderRadius is BorderRadius) {
        directionalDecoration = boxDecoration.copyWith(
          borderRadius: RTLLayoutService.convertBorderRadiusToRTL(
            boxDecoration.borderRadius as BorderRadius,
            isRTL,
          ),
        );
      }
    }

    return Container(
      alignment: directionalAlignment,
      padding: directionalPadding,
      color: color,
      decoration: directionalDecoration,
      foregroundDecoration: foregroundDecoration,
      width: width,
      height: height,
      constraints: constraints,
      margin: directionalMargin,
      transform: directionalTransform,
      transformAlignment: directionalTransformAlignment,
      clipBehavior: clipBehavior,
      child: child,
    );
  }
}