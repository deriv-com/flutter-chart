import 'package:deriv_chart/src/theme/painting_styles/chart_paiting_style.dart';
import 'package:flutter/material.dart';

/// Defines the style of markers.
class MarkerStyle extends ChartPaintingStyle {
  /// Creates marker style.
  const MarkerStyle({
    this.upColor = const Color(0xFF00A79E),
    this.downColor = const Color(0xFFCC2E3D),
    this.radius = 12.0,
    this.activeMarkerText = const TextStyle(
      color: Colors.white,
      fontSize: 10,
      height: 1.4,
    ),
  });

  /// Color of marker pointing up.
  final Color upColor;

  /// Color of marker pointing down.
  final Color downColor;

  /// Radius of a single marker.
  final double radius;

  /// Active marker text style.
  final TextStyle activeMarkerText;
}
