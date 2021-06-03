import 'package:deriv_chart/src/add_ons/indicators_ui/callbacks.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/indicator_config.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/indicator_item.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/roc/roc_indicator_item.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/models/roc_options.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/roc_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'roc_indicator_config.g.dart';

/// PRC Indicator configurations.
@JsonSerializable()
class ROCIndicatorConfig extends IndicatorConfig {
  /// Initializes
  const ROCIndicatorConfig({
    this.period = 14,
    this.fieldType = 'close',
  }) : super(isOverlay: false);

  /// Initializes from JSON.
  factory ROCIndicatorConfig.fromJson(Map<String, dynamic> json) =>
      _$ROCIndicatorConfigFromJson(json);

  /// Unique name for this indicator.
  static const String name = 'PRC';

  @override
  Map<String, dynamic> toJson() => _$ROCIndicatorConfigToJson(this)
    ..putIfAbsent(IndicatorConfig.nameKey, () => name);

  /// The period
  final int period;

  /// Field type
  final String fieldType;

  @override
  Series getSeries(IndicatorInput indicatorInput) => ROCSeries.fromIndicator(
        IndicatorConfig.supportedFieldTypes[fieldType](indicatorInput),
        this,
        rocOptions: ROCOptions(period: period),
      );

  @override
  IndicatorItem getItem(
    UpdateIndicator updateIndicator,
    VoidCallback deleteIndicator,
  ) =>
      ROCIndicatorItem(
        config: this,
        updateIndicator: updateIndicator,
        deleteIndicator: deleteIndicator,
      );
}
