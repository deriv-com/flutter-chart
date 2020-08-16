import 'package:deriv_chart/src/theme/painting_styles/chart_paiting_style.dart';
import 'package:flutter/material.dart';

class CandleStyle extends ChartPaintingStyle {
  CandleStyle({
    this.positiveColor,
    this.negativeColor,
    this.lineColor,
  });

  final Color positiveColor;
  final Color negativeColor;
  final Color lineColor;
}
