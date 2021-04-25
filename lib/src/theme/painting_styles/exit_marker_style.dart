import 'package:deriv_chart/src/theme/colors.dart';
import 'package:deriv_chart/src/theme/painting_styles/chart_painting_style.dart';
import 'package:flutter/material.dart';

/// Defines the style of an exit marker.
class ExitMarkerStyle extends ChartPaintingStyle {
  /// Creates an exit marker style.
  const ExitMarkerStyle({
    this.radius = 2.5,
    this.color = DarkThemeColors.accentGreen,
  });

  /// Radius of the marker.
  final double radius;

  /// Color of the marker.
  final Color color;
}
