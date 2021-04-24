// @dart=2.9

import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/indicators_ui/indicator_config.dart';
import 'package:deriv_chart/src/deriv_chart/indicators_ui/indicator_item.dart';
import 'package:deriv_chart/src/deriv_chart/indicators_ui/rsi/rsi_indicator_item.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/models/rsi_options.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/rsi_series.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../callbacks.dart';

part 'rsi_indicator_config.g.dart';

/// RSI Indicator configurations.
@JsonSerializable()
class RSIIndicatorConfig extends IndicatorConfig {
  /// Initializes
  const RSIIndicatorConfig({
    this.period = 14,
    this.fieldType = 'close',
    this.overBoughtPrice = 80,
    this.overSoldPrice = 20,
    this.lineStyle = const LineStyle(color: Colors.white),
    this.zeroHorizontalLinesStyle = const LineStyle(
      color: Colors.red,
    ),
    this.mainHorizontalLinesStyle = const LineStyle(
      color: Colors.white,
    ),
  }) : super(isOverlay: false);

  /// Initializes from JSON.
  factory RSIIndicatorConfig.fromJson(Map<String, dynamic> json) =>
      _$RSIIndicatorConfigFromJson(json);

  /// Unique name for this indicator.
  static const String name = 'RSI';

  @override
  Map<String, dynamic> toJson() => _$RSIIndicatorConfigToJson(this)
    ..putIfAbsent(IndicatorConfig.nameKey, () => name);

  /// The period to calculate the average gain and loss.
  final int period;

  /// The price to show the over bought line.
  final double overBoughtPrice;

  /// The price to show the over sold line.
  final double overSoldPrice;

  /// The RSI line style.
  final LineStyle lineStyle;

  /// The RSI zero horizontal line style.
  final LineStyle zeroHorizontalLinesStyle;

  /// The RSI horizontal lines style(overBought and overSold).
  final LineStyle mainHorizontalLinesStyle;

  /// Field type
  final String fieldType;

  @override
  Series getSeries(IndicatorInput indicatorInput) => RSISeries.fromIndicator(
        IndicatorConfig.supportedFieldTypes[fieldType](indicatorInput),
        this,
        rsiOptions: RSIOptions(period: period),
      );

  @override
  IndicatorItem getItem(
    UpdateIndicator updateIndicator,
    VoidCallback deleteIndicator,
  ) =>
      RSIIndicatorItem(
        config: this,
        updateIndicator: updateIndicator,
        deleteIndicator: deleteIndicator,
      );
}
