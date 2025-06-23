import 'dart:ui';

import 'package:deriv_chart/src/theme/painting_styles/data_series_style.dart';
import 'package:equatable/equatable.dart';

/// Defines the style of painting candle data.
class CandleStyle extends DataSeriesStyle with EquatableMixin {
  /// Initializes a style that defines the style of painting candle data.
  const CandleStyle({
    this.candleBullishBodyColor = const Color(0xFF00C390),
    this.candleBearishBodyColor = const Color(0xFFDE0040),
    this.neutralColor = const Color(0xFF6E6E6E),
    this.candleBullishWickColor = const Color(0xFF00C390),
    this.candleBearishWickColor = const Color(0xFFDE0040),
  });

  /// Color of candles in which the price moved HIGHER during their period.
  final Color candleBullishBodyColor;

  /// Color of candles in which the price moved LOWER during their period.
  final Color candleBearishBodyColor;

  /// Neutral color for candles in which the price remains same
  /// or The vertical line inside candle which represents high/low.
  final Color neutralColor;

  /// Color of wicks in which the price moved HIGHER during their period.
  final Color candleBullishWickColor;

  /// Color of wicks in which the price moved LOWER during their period.
  final Color candleBearishWickColor;

  @override
  String toString() =>
      '${super.toString()}$candleBullishBodyColor, $candleBearishBodyColor, $neutralColor, $candleBullishWickColor, $candleBearishWickColor';

  @override
  List<Object> get props => <Object>[
        candleBullishBodyColor,
        candleBearishBodyColor,
        neutralColor,
        candleBullishWickColor,
        candleBearishWickColor,
      ];
}
