import 'package:deriv_chart/src/theme/painting_styles/chart_painting_style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Barrier style
class BarrierStyle extends ChartPaintingStyle {
  /// Initializes
  const BarrierStyle({
    this.color = const Color(0xFF00A79E),
    this.valueBackgroundColor = Colors.transparent,
    this.hasLine = true,
    this.isDashed = false,
    this.textStyle = const TextStyle(
      fontSize: 10,
      height: 1.3,
      fontWeight: FontWeight.normal,
      color: Colors.white,
    ),
  });

  /// Color of the barrier
  final Color color;

  /// Style of the title and value
  final TextStyle textStyle;

  /// Whether the barrier has line.
  final bool hasLine;

  /// Whether barrier's line should be dashed.
  final bool isDashed;

  /// Value label background color
  final Color valueBackgroundColor;
}
