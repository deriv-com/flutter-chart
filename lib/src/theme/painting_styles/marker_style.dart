import 'package:deriv_chart/src/theme/painting_styles/chart_paiting_style.dart';
import 'package:flutter/material.dart';

/// Defines the style of markers.
class MarkerStyle extends ChartPaintingStyle {
  /// Creates marker style.
  const MarkerStyle({
    this.color = Colors.red,
  });

  /// Marker color.
  final Color color;
}
