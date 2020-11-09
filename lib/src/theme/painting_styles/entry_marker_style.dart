import 'package:deriv_chart/src/theme/colors.dart';
import 'package:deriv_chart/src/theme/painting_styles/chart_painting_style.dart';
import 'package:flutter/material.dart';

/// Defines the style of entry marker.
class EntryMarkerStyle extends ChartPaintingStyle {
  /// Creates entry marker style.
  const EntryMarkerStyle({
    this.radius = 2.5,
    this.borderWidth = 1.0,
    this.borderColor = BrandColors.coral,
  });

  /// Marker radius.
  final double radius;

  /// Width of inner border.
  final double borderWidth;

  /// Color of inner border.
  final Color borderColor;
}
