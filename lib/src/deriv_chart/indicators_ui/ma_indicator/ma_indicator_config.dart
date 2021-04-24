

import 'package:deriv_chart/src/deriv_chart/indicators_ui/callbacks.dart';
import 'package:deriv_chart/src/deriv_chart/indicators_ui/indicator_item.dart';
import 'package:deriv_chart/src/deriv_chart/indicators_ui/ma_indicator/ma_indicator_item.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/ma_series.dart';
import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/models/indicator_options.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../indicator_config.dart';

part 'ma_indicator_config.g.dart';

/// Moving Average indicator config
@JsonSerializable()
class MAIndicatorConfig extends IndicatorConfig {
  /// Initializes
  const MAIndicatorConfig({
    this.period = 50,
    this.movingAverageType = MovingAverageType.simple,
    this.fieldType = 'close',
    this.lineStyle = const LineStyle(color: Colors.yellow, thickness: 0.6),
    this.offset = 0,
  }) : super();

  /// Initializes from JSON.
  factory MAIndicatorConfig.fromJson(Map<String, dynamic> json) =>
      _$MAIndicatorConfigFromJson(json);

  /// Unique name for this indicator.
  static const String name = 'moving_average';

  @override
  Map<String, dynamic> toJson() => _$MAIndicatorConfigToJson(this)
    ..putIfAbsent(IndicatorConfig.nameKey, () => name);

  /// Moving Average period
  final int period;

  /// Moving Average type
  final MovingAverageType movingAverageType;

  /// Field type
  final String fieldType;

  /// MA line style
  final LineStyle lineStyle;

  /// The offset of this indicator.
  final int offset;

  @override
  Series getSeries(IndicatorInput indicatorInput) => MASeries.fromIndicator(
        IndicatorConfig.supportedFieldTypes[fieldType]!(indicatorInput),
        options: MAOptions(period: period, type: movingAverageType),
        offset: offset,
        style: lineStyle,
      );

  @override
  IndicatorItem getItem(
    UpdateIndicator updateIndicator,
    VoidCallback deleteIndicator,
  ) =>
      MAIndicatorItem(
        config: this,
        updateIndicator: updateIndicator,
        deleteIndicator: deleteIndicator,
      );
}
