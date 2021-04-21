import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/indicators_ui/callbacks.dart';
import 'package:deriv_chart/src/deriv_chart/indicators_ui/indicator_item.dart';
import 'package:deriv_chart/src/deriv_chart/indicators_ui/zigzag_indicator/zigzag_indicator_item.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/zigzag_series.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../indicator_config.dart';

part 'zigzag_indicator_config.g.dart';

/// ZigZag indicator config
@JsonSerializable()
class ZigZagIndicatorConfig extends IndicatorConfig {
  /// Initializes
  const ZigZagIndicatorConfig({
    double distance,
    LineStyle lineStyle,
  })  : distance = distance ?? 10,
        lineStyle =
            lineStyle ?? const LineStyle(thickness: 0.9, color: Colors.blue),
        super();

  /// Initializes from JSON.
  factory ZigZagIndicatorConfig.fromJson(Map<String, dynamic> json) =>
      _$ZigZagIndicatorConfigFromJson(json);

  /// Unique name for this indicator.
  static const String name = 'zigzag';

  @override
  Map<String, dynamic> toJson() => _$ZigZagIndicatorConfigToJson(this)
    ..putIfAbsent(IndicatorConfig.nameKey, () => name);

  /// ZigZag distance in %
  final double distance;

  /// ZigZag line style
  final LineStyle lineStyle;

  @override
  Series getSeries(IndicatorInput indicatorInput) => ZigZagSeries(
        indicatorInput,
        distance: distance,
        style: lineStyle,
      );

  @override
  IndicatorItem getItem(
    UpdateIndicator updateIndicator,
    VoidCallback deleteIndicator,
  ) =>
      ZigZagIndicatorItem(
        config: this,
        updateIndicator: updateIndicator,
        deleteIndicator: deleteIndicator,
      );
}
