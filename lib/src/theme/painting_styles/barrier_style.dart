import 'package:deriv_chart/src/theme/painting_styles/chart_painting_style.dart';
import 'package:flutter/material.dart';

/// Barrier style
abstract class BarrierStyle extends ChartPaintingStyle {
  /// Initializes
  const BarrierStyle({
    this.color,
    this.titleBackgroundColor,
    this.hasLine,
    this.isDashed,
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

  /// Title label background color
  final Color titleBackgroundColor;

  @override
  String toString() =>
      '${super.toString()}$color, ${textStyle.toStringShort()}, $hasLine, $isDashed, $titleBackgroundColor';
}

/// Horizontal barrier style
class HorizontalBarrierStyle extends BarrierStyle {
  /// Initializes
  const HorizontalBarrierStyle({
    this.labelShape = LabelShape.rectangle,
    Color color = const Color(0xFF00A79E),
    Color titleBackgroundColor = Colors.transparent,
    bool hasLine = true,
    bool isDashed = true,
    this.hasBlinkingDot = false,
    TextStyle textStyle = const TextStyle(
      fontSize: 10,
      height: 1.3,
      fontWeight: FontWeight.normal,
      color: Colors.white,
    ),
  }) : super(
          color: color,
          titleBackgroundColor: titleBackgroundColor,
          hasLine: hasLine,
          isDashed: isDashed,
          textStyle: textStyle,
        );

  /// Label shape
  final LabelShape labelShape;

  /// Whether to have a blinking dot animation where barrier and chart data are intersected.
  final bool hasBlinkingDot;

  @override
  String toString() => '${super.toString()}, $hasBlinkingDot $labelShape';
}

/// Vertical barrier style
class VerticalBarrierStyle extends BarrierStyle {
  /// Initializes
  const VerticalBarrierStyle({
    Color color = Colors.grey,
    Color titleBackgroundColor = Colors.transparent,
    bool hasLine = true,
    bool isDashed = true,
    TextStyle textStyle = const TextStyle(
      fontSize: 10,
      height: 1.3,
      fontWeight: FontWeight.normal,
      color: Colors.white,
    ),
  }) : super(
          color: color,
          titleBackgroundColor: titleBackgroundColor,
          hasLine: hasLine,
          isDashed: isDashed,
          textStyle: textStyle,
        );
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

/// Label shape
enum LabelShape {
  /// Rectangle
  rectangle,

  /// pentagon
  pentagon,
}
