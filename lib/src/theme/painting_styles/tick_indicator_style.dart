import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/theme/painting_styles/chart_painting_style.dart';
import 'package:flutter/material.dart';

/// For defining current tick indicator style
class TickIndicatorStyle extends ChartPaintingStyle {
  /// Initializes
  const TickIndicatorStyle({
    this.color = const Color(0xFFFF444F),
    this.lineThickness = 1,
    this.labelShape = LabelShape.pentagon,
    this.blinking = true,
    this.labelStyle = const TextStyle(
        fontSize: 10,
        height: 1.3,
        fontWeight: FontWeight.normal,
        color: Color(0xFFFFFFFF)),
  });

  /// The color of label, dashed-line and current tick dot.
  final Color color;

  /// Thickness of the dashed line
  final double lineThickness;

  /// The text style of the current tick indicator label on the Y-Axis
  final TextStyle labelStyle;

  /// Label shape
  final LabelShape labelShape;

  /// Whether has blinking animation.
  final bool blinking;
}

/// Label shape
enum LabelShape {
  /// Rectangle
  rectangle,

  /// pentagon
  pentagon,
}
