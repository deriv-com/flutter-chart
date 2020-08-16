import 'package:deriv_chart/src/theme/painting_styles/chart_paiting_style.dart';
import 'package:flutter/material.dart';

class LineStyle extends ChartPaintingStyle {
  const LineStyle({
    this.color,
    this.areaColor,
    this.thickness = 1,
  });

  final Color color;
  final Color areaColor;
  final double thickness;
}
