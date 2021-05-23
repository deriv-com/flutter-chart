import 'package:deriv_chart/src/deriv_chart/indicators_ui/ma_indicator/ma_indicator_config.dart';
import 'package:deriv_chart/src/middle_layer/data_visualization/chart_series/indicators_series/ma_env_series.dart';
import 'package:deriv_chart/src/middle_layer/data_visualization/chart_series/indicators_series/ma_series.dart';
import 'package:deriv_chart/src/middle_layer/data_visualization/chart_series/indicators_series/models/ma_env_options.dart';
import 'package:deriv_chart/src/middle_layer/data_visualization/chart_series/series.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../callbacks.dart';
import '../indicator_config.dart';
import '../indicator_item.dart';
import 'ma_env_indicator_item.dart';

part 'ma_env_indicator_config.g.dart';

/// Moving Average Envelope Indicator Config
@JsonSerializable()
class MAEnvIndicatorConfig extends MAIndicatorConfig {
  /// Initializes
  const MAEnvIndicatorConfig({
    int period,
    MovingAverageType movingAverageType,
    String fieldType,
    double shift,
    ShiftType shiftType,
  })  : shift = shift ?? 5,
        shiftType = shiftType ?? ShiftType.percent,
        super(
            period: period,
            movingAverageType: movingAverageType,
            fieldType: fieldType);

  /// Initializes from JSON.
  factory MAEnvIndicatorConfig.fromJson(Map<String, dynamic> json) =>
      _$MAEnvIndicatorConfigFromJson(json);

  /// Unique name for this indicator.
  static const String name = 'moving_envelope_average';

  @override
  Map<String, dynamic> toJson() => _$MAEnvIndicatorConfigToJson(this)
    ..putIfAbsent(IndicatorConfig.nameKey, () => name);

  /// Moving Average Envelope shift type
  final ShiftType shiftType;

  /// Moving Average Envelope shift
  final double shift;

  @override
  Series getSeries(IndicatorInput indicatorInput) => MAEnvSeries.fromIndicator(
      IndicatorConfig.supportedFieldTypes[fieldType](indicatorInput),
      maEnvOptions: MAEnvOptions(
        period: period,
        movingAverageType: movingAverageType,
        shift: shift,
        shiftType: shiftType,
      ));

  @override
  IndicatorItem getItem(
    UpdateIndicator updateIndicator,
    VoidCallback deleteIndicator,
  ) =>
      MAEnvIndicatorItem(
        config: this,
        updateIndicator: updateIndicator,
        deleteIndicator: deleteIndicator,
      );
}
