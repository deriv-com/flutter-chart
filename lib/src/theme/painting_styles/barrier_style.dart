import 'package:deriv_chart/src/theme/painting_styles/chart_painting_style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Barrier style
abstract class BarrierStyle extends ChartPaintingStyle {
  /// Initializes
  const BarrierStyle({
    this.color,
    this.valueBackgroundColor,
    this.hasLine,
    this.isDashed,
    this.intersectionDotStyle,
    this.textStyle,
  });

  /// Color of the barrier
  final Color color;

  /// Style of the title and value
  final TextStyle textStyle;

  /// Whether the barrier has line.
  final bool hasLine;

  /// Whether barrier's line should be dashed.
  final bool isDashed;

  /// Value label background color
  final Color valueBackgroundColor;

  /// The style of the dot where barrier and chart data are intersected.
  final IntersectionDotStyle intersectionDotStyle;

  @override
  String toString() =>
      '${super.toString()}$color, ${textStyle.toStringShort()}, $hasLine, $isDashed, $valueBackgroundColor';
}

/// Horizontal barrier style
class HorizontalBarrierStyle extends BarrierStyle {
  /// Initializes
  const HorizontalBarrierStyle({
    this.arrowType = BarrierArrowType.none,
    Color color = const Color(0xFF00A79E),
    Color valueBackgroundColor = Colors.transparent,
    bool hasLine = true,
    bool isDashed = true,
    IntersectionDotStyle intersectionDotStyle,
    TextStyle textStyle = const TextStyle(
      fontSize: 10,
      height: 1.3,
      fontWeight: FontWeight.normal,
      color: Colors.white,
    ),
  }) : super(
          color: color,
          valueBackgroundColor: valueBackgroundColor,
          hasLine: hasLine,
          isDashed: isDashed,
          textStyle: textStyle,
          intersectionDotStyle: intersectionDotStyle,
        );

  /// Arrow type
  final BarrierArrowType arrowType;

  @override
  String toString() => '${super.toString()}, $arrowType';
}

/// Vertical barrier style
class VerticalBarrierStyle extends BarrierStyle {
  /// Initializes
  const VerticalBarrierStyle({
    Color color = Colors.grey,
    Color valueBackgroundColor = Colors.transparent,
    bool hasLine = true,
    bool isDashed = true,
    IntersectionDotStyle intersectionDotStyle,
    TextStyle textStyle = const TextStyle(
      fontSize: 10,
      height: 1.3,
      fontWeight: FontWeight.normal,
      color: Colors.white,
    ),
  }) : super(
          color: color,
          valueBackgroundColor: valueBackgroundColor,
          hasLine: hasLine,
          isDashed: isDashed,
          textStyle: textStyle,
          intersectionDotStyle: intersectionDotStyle,
        );
}

/// Style of the dot where two lines are intersected.
class IntersectionDotStyle extends ChartPaintingStyle {
  /// Initializes
  const IntersectionDotStyle({
    this.color = Colors.redAccent,
    this.radius = 1,
    this.filled = false,
  });

  /// Color of the dot
  final Color color;

  /// Radius of the dot
  final double radius;

  /// Whether dot is filled or not.
  final bool filled;
}

/// The type of arrow on top/bottom of barrier label (Horizontal barrier).
enum BarrierArrowType {
  /// No arrows
  none,

  /// Upward arrows on top of the label
  upward,

  /// Downward arrows on bottom of the label
  downward,
}
