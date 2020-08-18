import 'package:deriv_chart/src/theme/painting_styles/chart_paiting_style.dart';
import 'package:flutter/material.dart';

/// Defines the style of painting line data
class LineStyle extends ChartPaintingStyle {
  /// Initializes
  const LineStyle({
    this.color = const Color(0xFF85ACB0),
    this.hasArea = true,
    this.thickness = 1,
  });

  /// Line color
  final Color color;

  /// Starting color of the gradient area under the line chart.
  ///
  /// If null, line chart won't have a gradient color area.
  final bool hasArea;

  /// Line thickness
  final double thickness;
}
