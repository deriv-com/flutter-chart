import 'package:deriv_chart/src/middle_layer/data_visualization/chart_series/indicators_series/fcb_series.dart';
import 'package:deriv_chart/src/middle_layer/data_visualization/chart_series/series.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../callbacks.dart';
import '../indicator_config.dart';
import '../indicator_item.dart';
import 'fcb_indicator_item.dart';

part 'fcb_indicator_config.g.dart';

/// Fractal Chaos Band Indicator Config
@JsonSerializable()
class FractalChaosBandIndicatorConfig extends IndicatorConfig {
  /// Initializes
  const FractalChaosBandIndicatorConfig({this.channelFill}) : super();

  /// Initializes from JSON.
  factory FractalChaosBandIndicatorConfig.fromJson(Map<String, dynamic> json) =>
      _$FractalChaosBandIndicatorConfigFromJson(json);

  /// if it's true the channel between two lines will be filled
  final bool channelFill;

  @override
  Series getSeries(IndicatorInput indicatorInput) =>
      FractalChaosBandSeries(indicatorInput);

  /// Unique name for this indicator.
  static const String name = 'fcb';

  @override
  Map<String, dynamic> toJson() => _$FractalChaosBandIndicatorConfigToJson(this)
    ..putIfAbsent(IndicatorConfig.nameKey, () => name);

  @override
  IndicatorItem getItem(
    UpdateIndicator updateIndicator,
    VoidCallback deleteIndicator,
  ) =>
      FractalChaosBandIndicatorItem(
        config: this,
        updateIndicator: updateIndicator,
        deleteIndicator: deleteIndicator,
      );
}
