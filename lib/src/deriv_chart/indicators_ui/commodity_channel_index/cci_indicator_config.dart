import 'package:deriv_chart/src/deriv_chart/indicators_ui/callbacks.dart';
import 'package:deriv_chart/src/deriv_chart/indicators_ui/commodity_channel_index/cci_indicator_item.dart';
import 'package:deriv_chart/src/deriv_chart/indicators_ui/indicator_config.dart';
import 'package:deriv_chart/src/deriv_chart/indicators_ui/indicator_item.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/cci_series.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/models/cci_options.dart';
import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cci_indicator_config.g.dart';

/// Commodity Channel Index Indicator configurations.
@JsonSerializable()
class CCIIndicatorConfig extends IndicatorConfig {
  /// Initializes.
  const CCIIndicatorConfig({
    this.period = 20,
    this.overboughtValue = 100,
    this.oversoldValue = -100,
    this.lineStyle = const LineStyle(color: Colors.white),
  }) : super(isOverlay: false);

  /// Initializes from JSON.
  factory CCIIndicatorConfig.fromJson(Map<String, dynamic> json) =>
      _$CCIIndicatorConfigFromJson(json);

  /// Unique name for this indicator.
  static const String name = 'commodity_channel_index';

  @override
  Map<String, dynamic> toJson() => _$CCIIndicatorConfigToJson(this)
    ..putIfAbsent(IndicatorConfig.nameKey, () => name);

  /// The period to calculate the average gain and loss.
  final int period;

  /// Overbought value.
  final double overboughtValue;

  /// Oversold value.
  final double oversoldValue;

  /// The CCI line style.
  final LineStyle lineStyle;

  @override
  Series getSeries(IndicatorInput indicatorInput) => CCISeries(
        indicatorInput,
        CCIOptions(period),
        overboughtValue: overboughtValue,
        oversoldValue: oversoldValue,
      );

  @override
  IndicatorItem getItem(
    UpdateIndicator updateIndicator,
    VoidCallback deleteIndicator,
  ) =>
      CCIIndicatorItem(
        config: this,
        updateIndicator: updateIndicator,
        deleteIndicator: deleteIndicator,
      );
}
