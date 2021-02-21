import 'package:flutter/material.dart';

import 'barrier_style.dart';
import 'data_series_style.dart';

/// Defines the style of painting Scatter data.
class ScatterStyle extends DataSeriesStyle {
  /// Initializes a style that defines the style of painting line data.
  const ScatterStyle({
    this.color = const Color(0xFF85ACB0),
    this.radius = 1.5,
    HorizontalBarrierStyle lastTickStyle,
  }) : super(lastTickStyle: lastTickStyle);

  /// Dot color.
  final Color color;

  /// Dot radius.
  final double radius;

  @override
  String toString() => '${super.toString()}$color, $radius';
}
