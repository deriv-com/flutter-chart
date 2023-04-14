import 'package:deriv_chart/src/add_ons/indicators_ui/aroon/aroon_indicator_item.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/indicator_config.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/indicator_item.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/aroon_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/models/aroon_options.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series.dart';
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
    String? id,
    this.period = 14,
  }) : super(id: id, isOverlay: false);

  /// Initializes from JSON.
  factory AroonIndicatorConfig.fromJson(Map<String, dynamic> json) =>
      _$AroonIndicatorConfigFromJson(json);

  /// Unique name for this indicator.
  static const String name = 'Aroon';

  @override
  Map<String, dynamic> toJson() => _$AroonIndicatorConfigToJson(this)
    ..putIfAbsent(IndicatorConfig.nameKey, () => name);

  /// The period
  final int period;

  @override
  Series getSeries(IndicatorInput indicatorInput) => AroonSeries(
        indicatorInput,
        this,
        aroonOption: AroonOptions(period: period),
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
