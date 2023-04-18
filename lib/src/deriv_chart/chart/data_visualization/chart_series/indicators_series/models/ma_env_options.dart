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
  }) : super(period: period, type: movingAverageType);

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

  @override
  List<Object> get props => super.props
    ..add(shift)
    ..add(shiftType);
}
