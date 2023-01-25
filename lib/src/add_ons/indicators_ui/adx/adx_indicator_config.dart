import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/adx_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/models/adx_options.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../callbacks.dart';
import '../indicator_config.dart';
import '../indicator_item.dart';
import 'adx_indicator_item.dart';

part 'adx_indicator_config.g.dart';

/// adx Indicator Config
@JsonSerializable()
class ADXIndicatorConfig extends IndicatorConfig {
  /// Initializes
  const ADXIndicatorConfig({
    String? id,
    this.period = 14,
    this.smoothingPeriod = 14,
    this.showSeries = true,
    this.showChannelFill = false,
    this.showHistogram = false,
  }) : super(id: id, isOverlay: false);

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

  /// The period value for smoothing the ADX series.
  final int smoothingPeriod;

  /// Wether to add channel fill between the Positive and Negative DI Indicator.
  final bool showChannelFill;

  /// Wether to show the histogram Series or not.
  final bool showHistogram;

  /// Wether to show the Series or not.
  final bool showSeries;

  @override
  Series getSeries(IndicatorInput indicatorInput) => ADXSeries(
        indicatorInput,
        id: indicatorInput.id,
        config: this,
        adxOptions: ADXOptions(
          smoothingPeriod: smoothingPeriod,
          period: period,
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
