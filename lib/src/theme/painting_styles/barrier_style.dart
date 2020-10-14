import 'package:deriv_chart/src/theme/painting_styles/chart_painting_style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Barrier style
abstract class BarrierStyle extends ChartPaintingStyle {
  /// Initializes
  const BarrierStyle({
    this.color = const Color(0xFF00A79E),
    this.valueBackgroundColor = Colors.transparent,
    this.hasLine = true,
    this.isDashed = false,
    this.textStyle = const TextStyle(
      fontSize: 10,
      height: 1.3,
      fontWeight: FontWeight.normal,
      color: Colors.white,
    ),
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
