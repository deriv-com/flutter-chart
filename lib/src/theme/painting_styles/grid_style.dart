import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';

/// For defining the style of the chart's grid. (X and Y axes)
class GridStyle {
  /// Initializes
  const GridStyle({
    this.gridLineColor = const Color(0xFF151717),
    this.xLabelStyle = const TextStyle(
      fontSize: 10,
      height: 1.3,
      fontWeight: FontWeight.normal,
      color: Color(0xFFC2C2C2),
      fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
    ),
    this.yLabelStyle = const TextStyle(
      fontSize: 10,
      height: 1.3,
      fontWeight: FontWeight.normal,
      color: Colors.white,
      shadows: <Shadow>[
        Shadow(
          offset: Offset(0.0, 0.0),
          blurRadius: 4.0,
          color: Color.fromARGB(255, 0, 0, 0),
        ),
      ],
      fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
    ),
    this.labelHorizontalPadding = 8,
    this.lineThickness = 1,
    this.xLabelsAreaHeight = 24,
  });

  /// The color of the grid lines
  final Color gridLineColor;

  /// The text style of the labels on time axes
  final TextStyle xLabelStyle;

  /// The text style of the value axes
  final TextStyle yLabelStyle;

  /// Padding on the sides of the text label.
  final double labelHorizontalPadding;

  /// The line thickness of the grid lines
  final double lineThickness;

  /// Height of the area for x-axis labels.
  final double xLabelsAreaHeight;

  @override
  String toString() =>
      '${super.toString()}$gridLineColor, ${xLabelStyle.toStringShort()}, $lineThickness';
}
