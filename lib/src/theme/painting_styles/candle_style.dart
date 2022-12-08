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
  });

  /// Color of candles in which the price moved HIGHER during their period.
  final Color positiveColor;

  /// Color of candles in which the price moved LOWER during their period.
  final Color negativeColor;

  /// Neutral color for candles in which the price remains same
  /// or The vertical line inside candle which represents high/low.
  final Color neutralColor;

  @override
  String toString() =>
      '${super.toString()}$positiveColor, $negativeColor, $neutralColor';

  @override
  List<Object> get props =>
      <Object>[positiveColor, negativeColor, neutralColor];
}
