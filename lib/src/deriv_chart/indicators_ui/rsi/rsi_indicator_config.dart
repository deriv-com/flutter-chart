import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/indicators_ui/indicator_config.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/rsi_series.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';
import 'package:flutter/material.dart';

/// RSI Indicator configurations.
class RSIIndicatorConfig extends IndicatorConfig {
  /// Initializes
  const RSIIndicatorConfig({
    this.period = 14,
    this.overBoughtPrice = 80,
    this.overSoldPrice = 20,
    this.lineStyle = const LineStyle(color: Colors.white),
    this.zeroHorizontalLinesStyle = const LineStyle(
      color: Colors.red,
    ),
    this.mainHorizontalLinesStyle = const LineStyle(
      color: Colors.white,
    ),
  }) : super(isOverlay: false);

  /// The period to calculate the average gain and loss.
  final int period;

  /// The price to show the over bought line.
  final double overBoughtPrice;

  /// The price to show the over sold line.
  final double overSoldPrice;

  /// The RSI line style.
  final LineStyle lineStyle;

  /// The RSI zero horizontal line style.
  final LineStyle zeroHorizontalLinesStyle;

  /// The RSI horizontal lines style(overBought and overSold).
  final LineStyle mainHorizontalLinesStyle;

  @override
  Series getSeries(IndicatorInput indicatorInput) =>
      RSISeries.fromIndicator(CloseValueIndicator<Tick>(indicatorInput), this);
}
