import 'package:deriv_chart/src/add_ons/indicators_ui/ma_indicator/ma_indicator_config.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/dpo_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/ma_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/models/dpo_options.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../callbacks.dart';
import '../indicator_config.dart';
import '../indicator_item.dart';
import 'dpo_indicator_item.dart';

part 'dpo_indicator_config.g.dart';

/// Detrended Price Oscillator Indicator Config
@JsonSerializable()
class DPOIndicatorConfig extends MAIndicatorConfig {
  /// Initializes
  const DPOIndicatorConfig({
    int period = 14,
    MovingAverageType movingAverageType,
    String fieldType,
    this.isCentered = true,
  }) : super(
          period: period,
          movingAverageType: movingAverageType,
          fieldType: fieldType,
          isOverlay: false,
        );

  /// Initializes from JSON.
  factory DPOIndicatorConfig.fromJson(Map<String, dynamic> json) =>
      _$DPOIndicatorConfigFromJson(json);

  /// Unique name for this indicator.
  static const String name = 'dpo';

  /// Wether the indicator should be calculated `Centered` or not.
  final bool isCentered;

  @override
  Map<String, dynamic> toJson() => _$DPOIndicatorConfigToJson(this)
    ..putIfAbsent(IndicatorConfig.nameKey, () => name);

  @override
  Series getSeries(IndicatorInput indicatorInput) => DPOSeries.fromIndicator(
        IndicatorConfig.supportedFieldTypes[fieldType](indicatorInput),
        dpoOptions: DPOOptions(
          period: period,
          movingAverageType: movingAverageType,
          isCentered: isCentered,
        ),
      );

  @override
  IndicatorItem getItem(
    UpdateIndicator updateIndicator,
    VoidCallback deleteIndicator,
  ) =>
      DPOIndicatorItem(
        config: this,
        updateIndicator: updateIndicator,
        deleteIndicator: deleteIndicator,
      );
}
