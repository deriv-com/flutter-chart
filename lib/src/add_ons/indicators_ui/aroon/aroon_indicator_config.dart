import 'package:deriv_chart/src/add_ons/indicators_ui/aroon/aroon_indicator_item.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/indicator_config.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/indicator_item.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/aroon_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/models/aroon_options.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
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
    this.upLineStyle = const LineStyle(color: Colors.green),
    this.downLineStyle = const LineStyle(color: Colors.red),
    int pipSize = 4,
    bool showLastIndicator = false,
    String? title,
  }) : super(
          isOverlay: false,
          pipSize: pipSize,
          showLastIndicator: showLastIndicator,
          title: title ?? AroonIndicatorConfig.name,
        );

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

  /// Up line style.
  final LineStyle upLineStyle;

  /// Down line style.
  final LineStyle downLineStyle;

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
