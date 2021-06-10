import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/models/williams_r_options.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/williams_r_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../callbacks.dart';
import '../indicator_config.dart';
import '../indicator_item.dart';
import '../oscillator_lines/oscillator_lines_config.dart';
import 'williams_r_indicator_item.dart';

part 'williams_r_indicator_config.g.dart';

/// WilliamsR Indicator configurations.
@JsonSerializable()
class WilliamsRIndicatorConfig extends IndicatorConfig {
  /// Initializes
  const WilliamsRIndicatorConfig({
    this.period = 14,
    this.lineStyle = const LineStyle(color: Colors.white),
    this.zeroHorizontalLinesStyle = const LineStyle(color: Colors.red),
    this.oscillatorLimits = const OscillatorLinesConfig(
      overSoldPrice: -80,
      overBoughtPrice: -20,
      lineStyle: LineStyle(color: Colors.white),
    ),
  }) : super(isOverlay: false);

  /// Initializes from JSON.
  factory WilliamsRIndicatorConfig.fromJson(Map<String, dynamic> json) =>
      _$WilliamsRIndicatorConfigFromJson(json);

  /// Unique name for this indicator.
  static const String name = 'WilliamsR';

  @override
  Map<String, dynamic> toJson() => _$WilliamsRIndicatorConfigToJson(this)
    ..putIfAbsent(IndicatorConfig.nameKey, () => name);

  /// The period to calculate the average gain and loss.
  final int period;

  /// The WilliamsR line style.
  final LineStyle lineStyle;

  /// The WilliamsR zero horizontal line style.
  final LineStyle zeroHorizontalLinesStyle;

  /// Oscillator limit lines
  final OscillatorLinesConfig oscillatorLimits;

  @override
  Series getSeries(IndicatorInput indicatorInput) => WilliamsRSeries(
        indicatorInput,
        WilliamsROptions(period),
        overboughtValue: oscillatorLimits.overBoughtPrice,
        oversoldValue: oscillatorLimits.overSoldPrice,
      );

  @override
  IndicatorItem getItem(
    UpdateIndicator updateIndicator,
    VoidCallback deleteIndicator,
  ) =>
      WilliamsRIndicatorItem(
        config: this,
        updateIndicator: updateIndicator,
        deleteIndicator: deleteIndicator,
      );
}
