import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/alligator_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/models/alligator_options.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../callbacks.dart';
import '../indicator_config.dart';
import '../indicator_item.dart';
import 'alligator_indicator_item.dart';

part 'alligator_indicator_config.g.dart';

/// Bollinger Bands Indicator Config
@JsonSerializable()
class AlligatorIndicatorConfig extends IndicatorConfig {
  /// Initializes
  const AlligatorIndicatorConfig({
    this.jawPeriod = 13,
    this.teethPeriod = 8,
    this.lipsPeriod = 5,
    this.jawOffset = 8,
    this.teethOffset = 5,
    this.lipsOffset = 3,
    this.showLines = true,
    this.showFractal = false,
  }) : super();

  /// Initializes from JSON.
  factory AlligatorIndicatorConfig.fromJson(Map<String, dynamic> json) =>
      _$AlligatorIndicatorConfigFromJson(json);

  /// Unique name for this indicator.
  static const String name = 'alligator';

  @override
  Map<String, dynamic> toJson() => _$AlligatorIndicatorConfigToJson(this)
    ..putIfAbsent(IndicatorConfig.nameKey, () => name);

  /// Shift to future in jaw series
  final int jawOffset;

  /// Smoothing period for jaw series
  final int jawPeriod;

  /// Shift to future in teeth series
  final int teethOffset;

  /// Smoothing period for teeth series
  final int teethPeriod;

  /// Shift to future in lips series
  final int lipsOffset;

  /// Smoothing period for lips series
  final int lipsPeriod;

  /// show alligator lins  or not
  final bool showLines;

  /// show fractal indicator or not
  final bool showFractal;

  @override
  Series getSeries(IndicatorInput indicatorInput) => AlligatorSeries(
        indicatorInput,
        jawOffset: jawOffset,
        teethOffset: teethOffset,
        lipsOffset: lipsOffset,
        alligatorOptions: AlligatorOptions(
          jawPeriod: jawPeriod,
          teethPeriod: teethPeriod,
          lipsPeriod: lipsPeriod,
          showLines: showLines,
          showFractal: showFractal,
        ),
      );

  @override
  IndicatorItem getItem(
    UpdateIndicator updateIndicator,
    VoidCallback deleteIndicator,
  ) =>
      AlligatorIndicatorItem(
        config: this,
        updateIndicator: updateIndicator,
        deleteIndicator: deleteIndicator,
      );
}