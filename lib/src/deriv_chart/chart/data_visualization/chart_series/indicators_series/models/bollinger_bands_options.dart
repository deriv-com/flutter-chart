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
    this.upperLineStyle = const LineStyle(color: Colors.white),
    this.middleLineStyle = const LineStyle(color: Colors.white),
    this.lowerLineStyle = const LineStyle(color: Colors.white),
    this.fillColor = Colors.white12,
    this.showChannelFill = true,
    bool showLastIndicator = false,
  }) : super(
          period: period,
          type: movingAverageType,
          showLastIndicator: showLastIndicator,
        );

  /// Standard Deviation value
  final double standardDeviationFactor;

  /// Upper line style.
  final LineStyle upperLineStyle;

  /// Middle line style.
  final LineStyle middleLineStyle;

  /// Lower line style.
  final LineStyle lowerLineStyle;

  /// Fill color.
  final Color fillColor;

  /// Whether the area between upper and lower channel is filled.
  final bool showChannelFill;

  @override
  List<Object> get props => super.props
    ..addAll(<Object>[
      standardDeviationFactor,
      upperLineStyle,
      middleLineStyle,
      lowerLineStyle,
      fillColor,
      showChannelFill
    ]);
}
