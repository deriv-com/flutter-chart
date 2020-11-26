import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/theme/painting_styles/data_series_style.dart';
import 'package:flutter/material.dart';

/// Defines the style of painting line data
class LineStyle extends DataSeriesStyle {
  /// Initializes
  const LineStyle({
    this.color = const Color(0xFF85ACB0),
    this.thickness = 1,
    this.hasArea = false,
    HorizontalBarrierStyle lastTickStyle,
  }) : super(lastTickStyle: lastTickStyle);

  /// Line color
  final Color color;

  /// Line thickness
  final double thickness;

  /// Whether the line series has area or not
  final bool hasArea;

  @override
  String toString() => '${super.toString()}$color, $thickness, $hasArea';
}
