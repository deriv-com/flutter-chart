import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/ma_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/models/indicator_options.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../callbacks.dart';
import '../indicator_config.dart';
import '../indicator_item.dart';
import 'ma_indicator_item.dart';

part 'ma_indicator_config.g.dart';

/// Moving Average indicator config
@JsonSerializable()
class MAIndicatorConfig extends IndicatorConfig {
  /// Initializes
  const MAIndicatorConfig({
    int? period,
    MovingAverageType? movingAverageType,
    String? fieldType,
    LineStyle? lineStyle,
    int? offset,
    bool isOverlay = true,
    int pipSize = 4,
    bool showLastIndicator = false,
    String? title,
  })  : period = period ?? 50,
        movingAverageType = movingAverageType ?? MovingAverageType.simple,
        fieldType = fieldType ?? 'close',
        offset = offset ?? 0,
        lineStyle =
            lineStyle ?? const LineStyle(color: Colors.yellow, thickness: 0.6),
        super(
          isOverlay: isOverlay,
          pipSize: pipSize,
          showLastIndicator: showLastIndicator,
          title: title ?? MAIndicatorConfig.name,
        );

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
  String get shortTitle => 'MA';

  @override
  String get configSummary =>
      '$period, ${fieldType[0].toUpperCase()}, '
      '${movingAverageType.shortTitle}, $offset';

  @override
  Series getSeries(IndicatorInput indicatorInput) => MASeries.fromIndicator(
        IndicatorConfig.supportedFieldTypes[fieldType]!(indicatorInput),
        MAOptions(
          period: period,
          type: movingAverageType,
          showLastIndicator: showLastIndicator,
        ),
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
