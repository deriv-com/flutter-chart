import 'dart:ui';

import 'package:deriv_chart/src/theme/painting_styles/data_series_style.dart';
import 'package:equatable/equatable.dart';

/// Defines the style of painting candle data.
class CandleStyle extends DataSeriesStyle with EquatableMixin {
  /// Initializes a style that defines the style of painting candle data.
  const CandleStyle({
    this.positiveColor = const Color(0xFF00A79E),
    this.negativeColor = const Color(0xFFCC2E3D),
    this.neutralColor = const Color(0xFF6E6E6E),
    this.lineColor = const Color(0xFF6E6E6E),
  });

  /// Color of candles in which the price moved HIGHER during their period.
  final Color positiveColor;

  /// Color of candles in which the price moved LOWER during their period.
  final Color negativeColor;

  /// Color of candles in which the price remains same.
  final Color neutralColor;

  /// The vertical line inside candle which represents high/low.
  final Color lineColor;

  @override
  String toString() =>
      '${super.toString()}$positiveColor, $negativeColor, $neutralColor, $lineColor';

  @override
  List<Object> get props =>
      <Object>[positiveColor, negativeColor, neutralColor, lineColor];
}
