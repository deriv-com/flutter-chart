import 'package:deriv_chart/src/add_ons/indicators_ui/callbacks.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/indicator_config.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/indicator_item.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/roc/roc_indicator_item.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/models/roc_options.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/roc_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'roc_indicator_config.g.dart';

/// ROC Indicator configurations.
@JsonSerializable()
class ROCIndicatorConfig extends IndicatorConfig {
  /// Initializes
  const ROCIndicatorConfig({
    this.period = 14,
    this.fieldType = 'close',
    this.lineStyle,
    String? title,
  }) : super(isOverlay: false, title: title ?? ROCIndicatorConfig.name);

  /// Initializes from JSON.
  factory ROCIndicatorConfig.fromJson(Map<String, dynamic> json) =>
      _$ROCIndicatorConfigFromJson(json);

  /// Unique name for this indicator.
  static const String name = 'ROC';

  @override
  Map<String, dynamic> toJson() => _$ROCIndicatorConfigToJson(this)
    ..putIfAbsent(IndicatorConfig.nameKey, () => name);

  /// The period
  final int period;

  /// Field type
  final String fieldType;

  /// Line style.
  final LineStyle? lineStyle;

  @override
  Series getSeries(IndicatorInput indicatorInput) => ROCSeries.fromIndicator(
        IndicatorConfig.supportedFieldTypes[fieldType]!(indicatorInput),
        rocOptions: ROCOptions(period: period),
        lineStyle: lineStyle,
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
