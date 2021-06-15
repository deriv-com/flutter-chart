import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/smi_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../callbacks.dart';
import '../indicator_config.dart';
import '../indicator_item.dart';
import 'smi_indicator_item.dart';

part 'smi_indicator_config.g.dart';

/// SMI Indicator configurations.
@JsonSerializable()
class SMIIndicatorConfig extends IndicatorConfig {
  /// Initializes
  const SMIIndicatorConfig({
    this.period = 14,
    this.smoothingPeriod = 3,
    this.doubleSmoothingPeriod = 3,
    this.overboughtValue = 40,
    this.oversoldValue = -40,
  }) : super(isOverlay: false);

  /// Initializes from JSON.
  factory SMIIndicatorConfig.fromJson(Map<String, dynamic> json) =>
      _$SMIIndicatorConfigFromJson(json);

  /// Unique name for this indicator.
  static const String name = 'SMI';

  @override
  Map<String, dynamic> toJson() => _$SMIIndicatorConfigToJson(this)
    ..putIfAbsent(IndicatorConfig.nameKey, () => name);

  /// The period to calculate the average gain and loss.
  final int period;

  /// Smoothing period.
  final int smoothingPeriod;

  /// Souble smoothing period.
  final int doubleSmoothingPeriod;

  /// Overbought value.
  final double overboughtValue;

  /// Oversold value.
  final double oversoldValue;

  @override
  Series getSeries(IndicatorInput indicatorInput) => SMISeries(
        indicatorInput,
        overboughtValue: overboughtValue,
        oversoldValue: oversoldValue,
      );

  @override
  IndicatorItem getItem(
    UpdateIndicator updateIndicator,
    VoidCallback deleteIndicator,
  ) =>
      SMIIndicatorItem(
        config: this,
        updateIndicator: updateIndicator,
        deleteIndicator: deleteIndicator,
      );
}
