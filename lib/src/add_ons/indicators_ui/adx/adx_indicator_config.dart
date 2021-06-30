import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/adx_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../callbacks.dart';
import '../indicator_config.dart';
import '../indicator_item.dart';

part 'adx_indicator_config.g.dart';

/// adx Indicator Config
@JsonSerializable()
class ADXIndicatorConfig extends IndicatorConfig {
  /// Initializes
  const ADXIndicatorConfig({
    this.period = 14,
    this.smoothingPeriod = 14,
  }) : super();

  /// Initializes from JSON.
  factory ADXIndicatorConfig.fromJson(Map<String, dynamic> json) =>
      _$ADXIndicatorConfigFromJson(json);

  /// Unique name for this indicator.
  static const String name = 'adx';

  @override
  Map<String, dynamic> toJson() => _$ADXIndicatorConfigToJson(this)
    ..putIfAbsent(IndicatorConfig.nameKey, () => name);

  /// The period value for the ADX series.
  final int period;

  /// The period value for smoothing the ADX series;
  final int smoothingPeriod;

  @override
  Series getSeries(IndicatorInput indicatorInput) => ADXSeries(
        indicatorInput,
        bbOptions: ADXOptions(
          period: period,
          movingAverageType: movingAverageType,
          standardDeviationFactor: standardDeviation,
        ),
      );

  @override
  IndicatorItem getItem(
    UpdateIndicator updateIndicator,
    VoidCallback deleteIndicator,
  ) =>
      ADXIndicatorItem(
        config: this,
        updateIndicator: updateIndicator,
        deleteIndicator: deleteIndicator,
      );
}
