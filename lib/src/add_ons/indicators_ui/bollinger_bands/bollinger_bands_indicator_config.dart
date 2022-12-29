import 'package:deriv_chart/src/add_ons/indicators_ui/ma_indicator/ma_indicator_config.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/bollinger_bands_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/ma_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/models/bollinger_bands_options.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../callbacks.dart';
import '../indicator_config.dart';
import '../indicator_item.dart';
import 'bollinger_bands_indicator_item.dart';

part 'bollinger_bands_indicator_config.g.dart';

/// Bollinger Bands Indicator Config
@JsonSerializable()
class BollingerBandsIndicatorConfig extends MAIndicatorConfig {
  /// Initializes
  const BollingerBandsIndicatorConfig({
    String? id,
    int period = 50,
    MovingAverageType movingAverageType = MovingAverageType.simple,
    String fieldType = 'close',
    this.standardDeviation = 2,
  }) : super(
          id: id,
          period: period,
          movingAverageType: movingAverageType,
          fieldType: fieldType,
        );

  /// Initializes from JSON.
  factory BollingerBandsIndicatorConfig.fromJson(Map<String, dynamic> json) =>
      _$BollingerBandsIndicatorConfigFromJson(json);

  /// Unique name for this indicator.
  static const String name = 'bollinger_bands';

  @override
  Map<String, dynamic> toJson() => _$BollingerBandsIndicatorConfigToJson(this)
    ..putIfAbsent(IndicatorConfig.nameKey, () => name);

  /// Standard Deviation value
  final double standardDeviation;

  @override
  Series getSeries(IndicatorInput indicatorInput) =>
      BollingerBandSeries.fromIndicator(
        IndicatorConfig.supportedFieldTypes[fieldType]!(indicatorInput),
        bbOptions: BollingerBandsOptions(
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
      BollingerBandsIndicatorItem(
        config: this,
        updateIndicator: updateIndicator,
        deleteIndicator: deleteIndicator,
      );
}
