import 'package:deriv_chart/src/theme/painting_styles/bar_style.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';

import 'indicator_options.dart';

/// MACD Options.
class MACDOptions extends IndicatorOptions {
  ///Initializes a MACD Options.
  const MACDOptions({
    this.fastMAPeriod = 12,
    this.slowMAPeriod = 26,
    this.signalPeriod = 9,
    this.barStyle = const BarStyle(),
    this.lineStyle = const LineStyle(color: Colors.white),
    this.signalLineStyle = const LineStyle(color: Colors.redAccent),
    bool showLastIndicator = false,
    int pipSize = 4,
  }) : super(
          showLastIndicator: showLastIndicator,
          pipSize: pipSize,
        );

  /// The `period` for the `MACDFastMA`. Default is set to `12`.
  final int fastMAPeriod;

  /// The `period` for the `MACDSlowMA`. Default is set to `26`.
  final int slowMAPeriod;

  /// The `period` for the `MACDSignal`. Default is set to `9`.
  final int signalPeriod;

  /// Histogram bar style
  final BarStyle barStyle;

  /// Line style.
  final LineStyle lineStyle;

  /// Signal line style.
  final LineStyle signalLineStyle;

  @override
  List<int> get props => <int>[fastMAPeriod, slowMAPeriod, signalPeriod];
}
