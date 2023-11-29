import 'package:flutter/material.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';

import '../ma_series.dart';
import 'indicator_options.dart';

/// Moving Average Envelope indicator options.
class MAEnvOptions extends MAOptions {
  /// Initializes
  const MAEnvOptions({
    this.shift = 5,
    this.shiftType = ShiftType.percent,
    int period = 50,
    MovingAverageType movingAverageType = MovingAverageType.simple,
    this.upperLineStyle = const LineStyle(color: Colors.green),
    this.middleLineStyle = const LineStyle(color: Colors.blue),
    this.lowerLineStyle = const LineStyle(color: Colors.red),
    this.fillColor = Colors.white12,
    this.showChannelFill = true,
    bool showLastIndicator = false,
  }) : super(
          period: period,
          type: movingAverageType,
          showLastIndicator: showLastIndicator,
        );

  /// Shift value
  final double shift;

  /// Shift type could be Percent or Point
  final ShiftType shiftType;

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
      shift,
      shiftType,
      upperLineStyle,
      middleLineStyle,
      lowerLineStyle,
      fillColor,
      showChannelFill
    ]);
}
