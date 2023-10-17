import 'package:deriv_chart/src/theme/painting_styles/chart_painting_style.dart';
import 'package:flutter/material.dart';

/// Defines the style of an entry or exit marker.
class EntryExitMarkerStyle extends ChartPaintingStyle {
  /// Creates an entry marker style.
  const EntryExitMarkerStyle({
    this.radius = 4,
    this.borderWidth = 1.0,
    this.color = const Color(0xFF0E0E0E),
    this.borderColor = const Color(0xFFC2C2C2),
  });

  /// Radius of the marker.
  final double radius;

  /// Width of the inner border.
  final double borderWidth;

  /// Color of the inside of the circle.
  final Color color;

  /// Color of the inner border.
  final Color borderColor;
}
