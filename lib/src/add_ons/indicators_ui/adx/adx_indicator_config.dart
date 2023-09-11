import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/adx_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/models/adx_options.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/theme/painting_styles/bar_style.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
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
    this.period = 14,
    this.smoothingPeriod = 14,
    this.showSeries = true,
    this.showChannelFill = false,
    this.showHistogram = false,
    this.showShading = false,
    this.lineStyle = const LineStyle(color: Colors.white),
    this.positiveLineStyle = const LineStyle(color: Colors.green),
    this.negativeLineStyle = const LineStyle(color: Colors.red),
    this.barStyle = const BarStyle(),
    int pipSize = 4,
    bool showLastIndicator = false,
    String? title,
  }) : super(
          isOverlay: false,
          showLastIndicator: showLastIndicator,
          pipSize: pipSize,
          title: title ?? ADXIndicatorConfig.name,
        );

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

  /// Whether to add channel fill between the Positive and Negative DI
  /// Indicator.
  final bool showChannelFill;

  /// Whether to show the histogram Series or not.
  final bool showHistogram;

  /// Whether to show the shading or not.
  final bool showShading;

  /// Wether to show the Series or not.
  final bool showSeries;

  /// Line style.
  final LineStyle lineStyle;

  /// Positive line style.
  final LineStyle positiveLineStyle;

  /// Negative line style.
  final LineStyle negativeLineStyle;

  /// Histogram bar style
  final BarStyle barStyle;

  @override
  Series getSeries(IndicatorInput indicatorInput) => ADXSeries(
        indicatorInput,
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
