import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/indicators_ui/indicator_config.dart';
import 'package:deriv_chart/src/deriv_chart/indicators_ui/indicator_item.dart';
import 'package:deriv_chart/src/deriv_chart/indicators_ui/stochastic_oscillator_indicator/stochastic_oscillator_indicator_item.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/models/stochastic_oscillator_options.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/stochastic_oscillator_series.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../callbacks.dart';

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
    this.mainHorizontalLinesStyle = const LineStyle(
      color: Colors.white,
    ),
  }) : super(isOverlay: false);

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

  /// The horizontal lines style(overBought and overSold).
  final LineStyle mainHorizontalLinesStyle;

  /// Field type
  final String fieldType;

  /// if StochasticOscillator is smooth
  /// default is true
  final bool isSmooth;

  /// if show the overbought and oversold zones
  /// default is true
  final bool showZones;

  @override
  Series getSeries(IndicatorInput indicatorInput) => StochasticOscillatorSeries(
        IndicatorConfig.supportedFieldTypes[fieldType](indicatorInput),
        this,
        stochasticOscillatorOptions: StochasticOscillatorOptions(
            period: period, isSmooth: isSmooth, showZones: showZones),
      );

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
