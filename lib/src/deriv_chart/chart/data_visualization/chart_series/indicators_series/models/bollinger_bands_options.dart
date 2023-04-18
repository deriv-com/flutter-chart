import 'package:flutter/material.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';

import '../ma_series.dart';
import 'indicator_options.dart';

/// Bollinger Bands indicator options.
class BollingerBandsOptions extends MAOptions {
  /// Initializes
  const BollingerBandsOptions({
    this.standardDeviationFactor = 2,
    int period = 20,
    MovingAverageType movingAverageType = MovingAverageType.simple,
    this.upperLineStyle = const LineStyle(color: Colors.black),
    this.middleLineStyle = const LineStyle(color: Colors.black),
    this.lowerLineStyle = const LineStyle(color: Colors.black),
  }) : super(period: period, type: movingAverageType);

  /// Standard Deviation value
  final double standardDeviationFactor;

  /// Upper line style.
  final LineStyle upperLineStyle;

  /// Middle line style.
  final LineStyle middleLineStyle;

  /// Lower line style.
  final LineStyle lowerLineStyle;

  @override
  List<Object> get props => super.props..add(standardDeviationFactor);
}
