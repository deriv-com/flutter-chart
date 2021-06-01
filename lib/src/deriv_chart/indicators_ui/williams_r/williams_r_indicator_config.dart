import 'package:deriv_chart/src/deriv_chart/indicators_ui/indicator_config.dart';
import 'package:deriv_chart/src/deriv_chart/indicators_ui/indicator_item.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/models/williams_r_options.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/williams_r_series.dart';
import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../callbacks.dart';
import 'williams_r_indicator_item.dart';

part 'williams_r_indicator_config.g.dart';

/// WilliamsR Indicator configurations.
@JsonSerializable()
class WilliamsRIndicatorConfig extends IndicatorConfig {
  /// Initializes
  const WilliamsRIndicatorConfig({
    this.period = 14,
    this.overBoughtPrice = -20,
    this.overSoldPrice = -80,
    this.lineStyle = const LineStyle(color: Colors.white),
    this.zeroHorizontalLinesStyle = const LineStyle(color: Colors.red),
    this.mainHorizontalLinesStyle = const LineStyle(color: Colors.white),
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

  /// The price to show the over bought line.
  final double overBoughtPrice;

  /// The price to show the over sold line.
  final double overSoldPrice;

  /// The WilliamsR line style.
  final LineStyle lineStyle;

  /// The WilliamsR zero horizontal line style.
  final LineStyle zeroHorizontalLinesStyle;

  /// The WilliamsR horizontal lines style(overBought and overSold).
  final LineStyle mainHorizontalLinesStyle;

  @override
  Series getSeries(IndicatorInput indicatorInput) => WilliamsRSeries(
        indicatorInput,
        WilliamsROptions(period),
        overboughtValue: overBoughtPrice,
        oversoldValue: overSoldPrice,
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
