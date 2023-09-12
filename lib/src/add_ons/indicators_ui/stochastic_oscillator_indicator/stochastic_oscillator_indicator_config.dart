import 'package:deriv_chart/src/add_ons/indicators_ui/callbacks.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/indicator_item.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/oscillator_lines/oscillator_lines_config.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/stochastic_oscillator_indicator/stochastic_oscillator_indicator_item.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/models/stochastic_oscillator_options.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/stochastic_oscillator_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series.dart';

import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'stochastic_oscillator_indicator_config.g.dart';

/// Stochastic Oscillator Indicator configurations.
@JsonSerializable()
class StochasticOscillatorIndicatorConfig extends IndicatorConfig {
  /// Initializes
  const StochasticOscillatorIndicatorConfig({
    this.period = 14,
    this.fieldType = 'close',
    this.overBoughtPrice = 80,
    this.overSoldPrice = 20,
    this.showZones = false,
    this.isSmooth = true,
    this.lineStyle = const LineStyle(color: Colors.white),
    this.oscillatorLinesConfig = const OscillatorLinesConfig(
      overboughtValue: 80,
      oversoldValue: 20,
    ),
    this.fastLineStyle = const LineStyle(color: Colors.white),
    this.slowLineStyle = const LineStyle(color: Colors.red),
    int pipSize = 4,
    bool showLastIndicator = false,
    String? title,
  }) : super(
          isOverlay: false,
          pipSize: pipSize,
          showLastIndicator: showLastIndicator,
          title: title ?? StochasticOscillatorIndicatorConfig.name,
        );

  /// Initializes from JSON.
  factory StochasticOscillatorIndicatorConfig.fromJson(
          Map<String, dynamic> json) =>
      _$StochasticOscillatorIndicatorConfigFromJson(json);

  /// Unique name for this indicator.
  static const String name = 'StochasticOscillator';

  @override
  Map<String, dynamic> toJson() =>
      _$StochasticOscillatorIndicatorConfigToJson(this)
        ..putIfAbsent(IndicatorConfig.nameKey, () => name);

  /// The period to calculate the average gain and loss.
  final int period;

  /// The price to show the over bought line.
  final double overBoughtPrice;

  /// The price to show the over sold line.
  final double overSoldPrice;

  /// The line style.
  final LineStyle lineStyle;

  /// Config of overbought and oversold.
  final OscillatorLinesConfig oscillatorLinesConfig;

  /// Field type
  final String fieldType;

  /// if StochasticOscillator is smooth
  /// default is true
  final bool isSmooth;

  /// if show the overbought and oversold zones
  /// default is true
  final bool showZones;

  /// Fast line style.
  final LineStyle fastLineStyle;

  /// Slow line style.
  final LineStyle slowLineStyle;

  @override
  Series getSeries(IndicatorInput indicatorInput) => StochasticOscillatorSeries(
      IndicatorConfig.supportedFieldTypes[fieldType]!(indicatorInput), this,
      stochasticOscillatorOptions: StochasticOscillatorOptions(
        period: period,
        isSmooth: isSmooth,
      ));

  @override
  IndicatorItem getItem(
    UpdateIndicator updateIndicator,
    VoidCallback deleteIndicator,
  ) =>
      StochasticOscillatorIndicatorItem(
        config: this,
        updateIndicator: updateIndicator,
        deleteIndicator: deleteIndicator,
      );
}
