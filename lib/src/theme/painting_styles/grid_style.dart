import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// For defining the style of the chart's grid. (X and Y axes).
class GridStyle with EquatableMixin {
  /// Initializes a style for defining the style of the chart's grid.
  const GridStyle({
    this.gridLineColor = const Color(0xFF151717),
    this.gridLineHighlightColor = const Color(0xFF262A2A),
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
        Shadow(blurRadius: 4),
      ],
      fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
    ),
    this.labelHorizontalPadding = 8,
    this.lineThickness = 1,
    this.xLabelsAreaHeight = 24,
  });

  /// The color of the grid lines.
  final Color gridLineColor;

  /// The color of grid lines for highlighting some points on the chart.
  /// e.g. beginning of days/months.
  final Color gridLineHighlightColor;

  /// The text style of the labels on time axes
  final TextStyle xLabelStyle;

  /// The text style of the value axes
  final TextStyle yLabelStyle;

  /// Padding on the sides of the text label.
  final double labelHorizontalPadding;

  /// The line thickness of the grid lines.
  final double lineThickness;

  /// Height of the area for x-axis labels.
  final double xLabelsAreaHeight;

  @override
  String toString() =>
      '${super.toString()}$gridLineColor, ${xLabelStyle.toStringShort()}, '
      '${yLabelStyle.toStringShort()}, $lineThickness';

  @override
  List<Object> get props => <Object>[
        gridLineColor,
        gridLineHighlightColor,
        xLabelStyle,
        yLabelStyle,
        labelHorizontalPadding,
        lineThickness,
        xLabelsAreaHeight
      ];
}
