// @dart=2.9

import 'package:deriv_chart/src/theme/colors.dart';
import 'package:deriv_chart/src/theme/painting_styles/chart_painting_style.dart';
import 'package:flutter/material.dart';

/// Defines the style of an entry marker.
class EntryMarkerStyle extends ChartPaintingStyle {
  /// Creates an entry marker style.
  const EntryMarkerStyle({
    this.radius = 2.5,
    this.borderWidth = 1.0,
    this.borderColor = BrandColors.coral,
  });

  /// Radius of the marker.
  final double radius;

  /// Width of the inner border.
  final double borderWidth;

  /// Color of the inner border.
  final Color borderColor;
}
