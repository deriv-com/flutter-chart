import 'package:deriv_chart/src/add_ons/indicators_ui/awesome_oscillator/awesome_oscillator_indicator_item.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/awesome_oscillator_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/theme/painting_styles/bar_style.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../callbacks.dart';
import '../indicator_config.dart';
import '../indicator_item.dart';

part 'awesome_oscillator_indicator_config.g.dart';

/// Awesome Oscillator Indicator Config
@JsonSerializable()
class AwesomeOscillatorIndicatorConfig extends IndicatorConfig {
  /// Initializes
  const AwesomeOscillatorIndicatorConfig(
      {String? id, this.barStyle = const BarStyle()})
      : super(id: id, isOverlay: false);

  /// Initializes from JSON.
  factory AwesomeOscillatorIndicatorConfig.fromJson(
          Map<String, dynamic> json) =>
      _$AwesomeOscillatorIndicatorConfigFromJson(json);

  /// Histogram bar style
  final BarStyle barStyle;

  @override
  Series getSeries(IndicatorInput indicatorInput) =>
      AwesomeOscillatorSeries(indicatorInput, barStyle: barStyle);

  /// Unique name for this indicator.
  static const String name = 'AwesomeOscillator';

  @override
  Map<String, dynamic> toJson() =>
      _$AwesomeOscillatorIndicatorConfigToJson(this)
        ..putIfAbsent(IndicatorConfig.nameKey, () => name);

  @override
  IndicatorItem getItem(
    UpdateIndicator updateIndicator,
    VoidCallback deleteIndicator,
  ) =>
      AwesomeOscillatorIndicatorItem(
        config: this,
        updateIndicator: updateIndicator,
        deleteIndicator: deleteIndicator,
      );
}
