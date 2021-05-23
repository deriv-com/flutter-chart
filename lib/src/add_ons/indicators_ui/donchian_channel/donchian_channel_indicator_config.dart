import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/helpers/color_converter.dart';
import 'package:deriv_chart/src/middle_layer/data_visualization/chart_series/indicators_series/donchian_channels_series.dart';
import 'package:deriv_chart/src/middle_layer/data_visualization/chart_series/series.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../indicator_config.dart';
import '../indicator_item.dart';
import 'donchian_channel_indicator_item.dart';

part 'donchian_channel_indicator_config.g.dart';

/// Donchian Channel Indicator Config
@JsonSerializable()
@ColorConverter()
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

  /// Initializes from JSON.
  factory DonchianChannelIndicatorConfig.fromJson(Map<String, dynamic> json) =>
      _$DonchianChannelIndicatorConfigFromJson(json);

  /// Unique name for this indicator.
  static const String name = 'donchian_channel';

  @override
  Map<String, dynamic> toJson() => _$DonchianChannelIndicatorConfigToJson(this)
    ..putIfAbsent(IndicatorConfig.nameKey, () => name);

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
  Series getSeries(IndicatorInput indicatorInput) =>
      DonchianChannelsSeries.fromIndicator(
        IndicatorConfig.supportedFieldTypes['high'](indicatorInput),
        IndicatorConfig.supportedFieldTypes['low'](indicatorInput),
        this,
      );

  @override
  IndicatorItem getItem(updateIndicator, deleteIndicator) =>
      DonchianChannelIndicatorItem(
        config: this,
        updateIndicator: updateIndicator,
        deleteIndicator: deleteIndicator,
      );
}
