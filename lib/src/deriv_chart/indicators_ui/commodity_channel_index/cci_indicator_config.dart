import 'package:deriv_chart/src/deriv_chart/indicators_ui/indicator_config.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/cci_series.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/models/cci_options.dart';
import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';

/// Commodity Channel Index Indicator configurations.
class CCIIndicatorConfig extends IndicatorConfig {
  /// Initializes.
  const CCIIndicatorConfig({
    this.period = 20,
    this.overboughtValue = 100,
    this.oversoldValue = -100,
    this.lineStyle = const LineStyle(color: Colors.white),
  }) : super(isOverlay: false);

  /// The period to calculate the average gain and loss.
  final int period;

  /// Overbought value.
  final double overboughtValue;

  /// Oversold value.
  final double oversoldValue;

  /// The CCI line style.
  final LineStyle lineStyle;

  @override
  Series getSeries(IndicatorInput indicatorInput) => CCISeries(
        indicatorInput,
        CCIOptions(period),
        overboughtValue: overboughtValue,
        oversoldValue: oversoldValue,
      );
}
