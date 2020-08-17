import 'package:deriv_chart/src/theme/painting_styles/chart_paiting_style.dart';
import 'package:flutter/material.dart';

/// Defines the style of painting candle data
class CandleStyle extends ChartPaintingStyle {
  /// Initializes
  const CandleStyle({
    this.positiveColor,
    this.negativeColor,
    this.lineColor,
  });

  /// Color of candles in which the price moved HIGHER during their period
  final Color positiveColor;

  /// Color of candles in which the price moved LOWER during their period
  final Color negativeColor;

  /// The vertical line inside candle which represents high/low
  final Color lineColor;
}
