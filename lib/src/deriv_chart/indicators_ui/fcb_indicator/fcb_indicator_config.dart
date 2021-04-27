import 'package:deriv_chart/src/deriv_chart/indicators_ui/callbacks.dart';
import 'package:deriv_chart/src/deriv_chart/indicators_ui/fcb_indicator/fcb_indicator_item.dart';
import 'package:deriv_chart/src/deriv_chart/indicators_ui/indicator_item.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/fcb_series.dart';
import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../indicator_config.dart';

part 'fcb_indicator_config.g.dart';

/// Fractal Chaos Band Indicator Config
@JsonSerializable()
class FractalChaosBandIndicatorConfig extends IndicatorConfig {
  /// Initializes
  const FractalChaosBandIndicatorConfig({this.channelFill = false}) : super();

  /// if it's true the channel between two lines will be filled
  final bool channelFill;

  @override
  Series getSeries(IndicatorInput indicatorInput) =>
      FractalChaosBandSeries(indicatorInput, channelFill: channelFill);

  /// Initializes from JSON.
  factory FractalChaosBandIndicatorConfig.fromJson(Map<String, dynamic> json) =>
      _$FractalChaosBandIndicatorConfigFromJson(json);

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
