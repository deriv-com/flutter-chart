import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/indicators_ui/indicator_config.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/donchian_channels_series.dart';
import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:flutter/material.dart';

/// Donchian Channel Indicator Config
class DonchianChannelIndicatorConfig extends IndicatorConfig {
  /// Initializes
  const DonchianChannelIndicatorConfig({
    this.highPeriod = 10,
    this.lowPeriod = 10,
    this.showChannelFill = true,
    this.upperLineStyle = const LineStyle(color: Colors.red),
    this.middleLineStyle = const LineStyle(color: Colors.white),
    this.lowerLineStyle = const LineStyle(color: Colors.green),
    this.fillColor = Colors.white12,
  }) : super();

  /// Number of last candles used to calculate the highest value.
  final int highPeriod;

  /// Number of last candles used to calculate the lowest value.
  final int lowPeriod;

  /// Whether the area between upper and lower channel is filled.
  final bool showChannelFill;

  /// Upper line style.
  final LineStyle upperLineStyle;

  /// Middle line style.
  final LineStyle middleLineStyle;

  /// Lower line style.
  final LineStyle lowerLineStyle;

  /// Fill color.
  final Color fillColor;

  @override
  Series getSeries(IndicatorInput indicatorInput) => DonchianChannelsSeries.fromIndicator(
        IndicatorConfig.supportedFieldTypes['high'](indicatorInput),
        IndicatorConfig.supportedFieldTypes['low'](indicatorInput),
        this,
      );
}
