import 'dart:ui' show FontFeature;
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// For defining the style of the chart's grid. (X and Y axes)
class GridStyle with EquatableMixin {
  /// Initializes
  const GridStyle({
    this.gridLineColor = const Color(0xFF151717),
    this.labelStyle = const TextStyle(
      fontSize: 10,
      height: 1.3,
      fontWeight: FontWeight.normal,
      color: Color(0xFFC2C2C2),
      fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
    ),
    this.labelHorizontalPadding = 8,
    this.lineThickness = 1,
    this.xLabelsAreaHeight = 24,
  });

  /// The color of the grid lines
  final Color gridLineColor;

  /// The text style of the labels on time and value axes
  final TextStyle labelStyle;

  /// Padding on the sides of the text label.
  final double labelHorizontalPadding;

  /// The line thickness of the grid lines
  final double lineThickness;

  /// Height of the area for x-axis labels.
  final double xLabelsAreaHeight;

  @override
  String toString() =>
      '${super.toString()}$gridLineColor, ${labelStyle.toStringShort()}, $lineThickness';

  @override
  List<Object> get props => [
        gridLineColor,
        labelStyle,
        labelHorizontalPadding,
        lineThickness,
        xLabelsAreaHeight
      ];
}
