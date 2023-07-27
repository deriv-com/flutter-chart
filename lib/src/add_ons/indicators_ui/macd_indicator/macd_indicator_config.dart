import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/macd_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/models/macd_options.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/theme/painting_styles/bar_style.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../callbacks.dart';
import '../indicator_config.dart';
import '../indicator_item.dart';
import 'macd_indicator_item.dart';

part 'macd_indicator_config.g.dart';

/// MACD Indicator Config
@JsonSerializable()
class MACDIndicatorConfig extends IndicatorConfig {
  /// Initializes
  const MACDIndicatorConfig({
    this.fastMAPeriod = 12,
    this.slowMAPeriod = 26,
    this.signalPeriod = 9,
    this.barStyle = const BarStyle(),
    this.lineStyle = const LineStyle(color: Colors.white),
    this.signalLineStyle = const LineStyle(color: Colors.redAccent),
    int pipSize = 4,
    bool showLastIndicator = false,
    String? title,
  }) : super(
          isOverlay: false,
          pipSize: pipSize,
          showLastIndicator: showLastIndicator,
          title: title ?? MACDIndicatorConfig.name,
        );

  /// Initializes from JSON.
  factory MACDIndicatorConfig.fromJson(Map<String, dynamic> json) =>
      _$MACDIndicatorConfigFromJson(json);

  @override
  Series getSeries(IndicatorInput indicatorInput) => MACDSeries(
        indicatorInput,
        config: this,
        options: MACDOptions(
          fastMAPeriod: fastMAPeriod,
          slowMAPeriod: slowMAPeriod,
          signalPeriod: signalPeriod,
          barStyle: barStyle,
          lineStyle: lineStyle,
          signalLineStyle: signalLineStyle,
          showLastIndicator: showLastIndicator,
          pipSize: pipSize,
        ),
      );

  /// Unique name for this indicator.
  static const String name = 'macd';

  @override
  Map<String, dynamic> toJson() => _$MACDIndicatorConfigToJson(this)
    ..putIfAbsent(IndicatorConfig.nameKey, () => name);

  /// The period to calculate the fast MA value.
  final int fastMAPeriod;

  /// The period to calculate the Slow MA value.
  final int slowMAPeriod;

  /// The period to calculate the Signal value.
  final int signalPeriod;

  /// Histogram bar style
  final BarStyle barStyle;

  /// Line style.
  final LineStyle lineStyle;

  /// Signal line style.
  final LineStyle signalLineStyle;

  @override
  IndicatorItem getItem(
    UpdateIndicator updateIndicator,
    VoidCallback deleteIndicator,
  ) =>
      MACDIndicatorItem(
        config: this,
        updateIndicator: updateIndicator,
        deleteIndicator: deleteIndicator,
      );
}
