import 'package:deriv_chart/src/theme/painting_styles/chart_painting_style.dart';
import 'package:flutter/material.dart';

/// Defines the style of an accumulators entry spot.
class EntrySpotStyle extends ChartPaintingStyle {
  /// Creates an entry spot style.
  const EntrySpotStyle({
    this.mainColor = const Color(0xFF0E0E0E),
    this.borderColor = const Color(0xFFFF444F),
    this.strokeWidth = 1.0,
    this.radius = 2.5,
  });

  /// Main color of accumulators entry spot.
  final Color mainColor;

  /// Color of accumulators entry spot border.
  final Color borderColor;

  /// Width of the inner border.
  final double strokeWidth;

  /// Radius of a single spot.
  final double radius;
}
