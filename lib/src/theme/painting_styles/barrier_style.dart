import 'package:deriv_chart/src/theme/painting_styles/chart_painting_style.dart';
import 'package:flutter/material.dart';

/// Barrier style.
abstract class BarrierStyle extends ChartPaintingStyle {
  /// Initializes a barrier style
  const BarrierStyle({
    this.color = const Color(0xFF00A79E),
    this.titleBackgroundColor = const Color(0xFF0E0E0E),
    this.isDashed = true,
    this.textStyle = const TextStyle(
      fontSize: 10,
      height: 1.3,
      fontWeight: FontWeight.normal,
      color: Colors.white,
      fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
    ),
  });

  /// Color of the barrier.
  final Color color;

  /// Style of the title and value.
  final TextStyle textStyle;

  /// Whether barrier's line should be dashed.
  final bool isDashed;

  /// Title label background color.
  final Color titleBackgroundColor;

  @override
  String toString() =>
      '${super.toString()}$color, ${textStyle.toStringShort()}, $isDashed, '
      '$titleBackgroundColor';
}

/// Horizontal barrier style.
class HorizontalBarrierStyle extends BarrierStyle {
  /// Initializes a horizontal barrier style.
  const HorizontalBarrierStyle({
    this.labelShape = LabelShape.rectangle,
    this.labelHeight = 24,
    this.labelPadding = 4,
    Color color = const Color(0xFF00A79E),
    Color titleBackgroundColor = const Color(0xFF0E0E0E),
    this.secondaryBackgroundColor = const Color(0xFF607D8B),
    bool isDashed = true,
    this.hasBlinkingDot = false,
    Color? blinkingDotColor,
    this.arrowSize = 5,
    this.hasArrow = true,
    this.hasLine = true,
    TextStyle textStyle = const TextStyle(
      fontSize: 10,
      height: 1.3,
      fontWeight: FontWeight.normal,
      color: Colors.white,
      fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
    ),
  })  : blinkingDotColor = blinkingDotColor ?? color,
        super(
          color: color,
          titleBackgroundColor: titleBackgroundColor,
          isDashed: isDashed,
          textStyle: textStyle,
        );

  /// Label shape.
  final LabelShape labelShape;

  /// Height of label background.
  final double labelHeight;

  /// Padding of label.
  final double labelPadding;

  /// Whether to have a blinking dot animation where barrier and chart data
  /// are intersected.
  final bool hasBlinkingDot;

  /// The color of blinking dot.
  final Color blinkingDotColor;

  /// The size of the arrow.
  ///
  /// The arrow when barrier is out of Y-Axis range and its
  /// `HorizontalBarrier.visibility`
  /// is HorizontalBarrierVisibility.keepBarrierLabelVisible`.
  final double arrowSize;

  /// Whether to show an arrow pointing in the direction of the barrier,
  /// when the barrier is outside the y-axis range and visibility is set to
  /// `HorizontalBarrierVisibility.keepBarrierLabelVisible`.
  final bool hasArrow;

  /// Whether to draw a horizontal line to the current tick from the y-axis
  /// grid to the
  final bool hasLine;

  /// Color used to paint a second background of label if needed under the
  /// initial color.
  final Color secondaryBackgroundColor;

  @override
  String toString() => '${super.toString()}, $hasBlinkingDot $labelShape';
}

/// Vertical barrier style.
class VerticalBarrierStyle extends BarrierStyle {
  /// Initializes a vertical barrier style.
  const VerticalBarrierStyle({
    Color color = Colors.grey,
    Color titleBackgroundColor = Colors.transparent,
    bool isDashed = true,
    this.labelPosition = VerticalBarrierLabelPosition.auto,
    TextStyle textStyle = const TextStyle(
      fontSize: 10,
      height: 1.3,
      fontWeight: FontWeight.normal,
      color: Colors.white,
      fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
    ),
  }) : super(
          color: color,
          titleBackgroundColor: titleBackgroundColor,
          isDashed: isDashed,
          textStyle: textStyle,
        );

  /// Label position.
  final VerticalBarrierLabelPosition labelPosition;
}

/// The type of arrow on top/bottom of barrier label (Horizontal barrier).
enum BarrierArrowType {
  /// No arrows.
  none,

  /// Upward arrows on top of the label.
  upward,

  /// Downward arrows on bottom of the label.
  downward,
}

/// Label shape.
enum LabelShape {
  /// Rectangle.
  rectangle,

  /// Pentagon.
  pentagon,
}

/// Vertical barrier label position.
enum VerticalBarrierLabelPosition {
  /// Right if there is no space on left, otherwise left.
  auto,

  /// Always right.
  right,

  /// Always left.
  left,
}
