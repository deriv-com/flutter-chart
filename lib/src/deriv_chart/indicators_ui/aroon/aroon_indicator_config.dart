import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/indicators_ui/aroon/aroon_indicator_item.dart';
import 'package:deriv_chart/src/deriv_chart/indicators_ui/indicator_config.dart';
import 'package:deriv_chart/src/deriv_chart/indicators_ui/indicator_item.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/models/rsi_options.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/rsi_series.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../callbacks.dart';

part 'aroon_indicator_config.g.dart';

/// Aroon Indicator configurations.
@JsonSerializable()
class AroonIndicatorConfig extends IndicatorConfig {
  /// Initializes
  const AroonIndicatorConfig({
    this.period = 14,
  }) : super(isOverlay: false);

  /// Initializes from JSON.
  factory AroonIndicatorConfig.fromJson(Map<String, dynamic> json) =>
      _$AroonIndicatorConfigFromJson(json);

  /// Unique name for this indicator.
  static const String name = 'Aroon';

  @override
  Map<String, dynamic> toJson() => _$AroonIndicatorConfigToJson(this)
    ..putIfAbsent(IndicatorConfig.nameKey, () => name);

  /// The period to calculate the average gain and loss.
  final int period;


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
      AroonIndicatorItem(
        config: this,
        updateIndicator: updateIndicator,
        deleteIndicator: deleteIndicator,
      );
}
