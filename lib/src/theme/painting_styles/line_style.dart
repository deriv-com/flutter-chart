import 'package:deriv_chart/src/theme/painting_styles/data_series_style.dart';
import 'package:deriv_chart/src/theme/painting_styles/tick_indicator_style.dart';
import 'package:flutter/material.dart';

/// Defines the style of painting line data
class LineStyle extends DataSeriesStyle {
  /// Initializes
  const LineStyle({
    this.color = const Color(0xFF85ACB0),
    this.thickness = 1,
    this.hasArea = true,
    TickIndicatorStyle currentTickStyle,
  }) : super(currentTickStyle: currentTickStyle);

  /// Line color
  final Color color;

  /// Line thickness
  final double thickness;

  /// Whether the line series has area or not
  final bool hasArea;

  @override
  String toString() => '${super.toString()}($color, $thickness, $hasArea)';
}
