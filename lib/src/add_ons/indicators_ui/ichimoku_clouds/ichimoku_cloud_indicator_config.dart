import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/ichimoku_cloud_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/models/ichimoku_clouds_options.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../callbacks.dart';
import '../indicator_config.dart';
import '../indicator_item.dart';
import 'ichimoku_cloud_indicator_item.dart';

part 'ichimoku_cloud_indicator_config.g.dart';

/// Ichimoku Cloud Indicator Config
@JsonSerializable()
class IchimokuCloudIndicatorConfig extends IndicatorConfig {
  /// Initializes
  const IchimokuCloudIndicatorConfig({
    this.baseLinePeriod = 26,
    this.conversionLinePeriod = 9,
    this.laggingSpanOffset = -26,
    this.spanBPeriod = 52,
    this.conversionLineStyle = const LineStyle(color: Colors.indigo),
    this.baseLineStyle = const LineStyle(color: Colors.redAccent),
    this.spanALineStyle = const LineStyle(color: Colors.green),
    this.spanBLineStyle = const LineStyle(color: Colors.red),
    this.laggingLineStyle = const LineStyle(color: Colors.lime),
    String? title,
  }) : super(title: title ?? IchimokuCloudIndicatorConfig.name);

  /// Initializes from JSON.
  factory IchimokuCloudIndicatorConfig.fromJson(Map<String, dynamic> json) =>
      _$IchimokuCloudIndicatorConfigFromJson(json);

  /// Unique name for this indicator.
  static const String name = 'ichimoku';

  @override
  Map<String, dynamic> toJson() => _$IchimokuCloudIndicatorConfigToJson(this)
    ..putIfAbsent(IndicatorConfig.nameKey, () => name);

  /// The period to calculate the Conversion Line value.
  final int conversionLinePeriod;

  /// The period to calculate the Base Line value.
  final int baseLinePeriod;

  /// The period to calculate the Span B value.
  final int spanBPeriod;

  /// The period to calculate the Base Line value.
  final int laggingSpanOffset;

  /// Conversion line style.
  final LineStyle conversionLineStyle;

  /// Base line style.
  final LineStyle baseLineStyle;

  /// Span A style.
  final LineStyle spanALineStyle;

  /// Span B style.
  final LineStyle spanBLineStyle;

  /// Lagging line style.
  final LineStyle laggingLineStyle;

  @override
  Series getSeries(IndicatorInput indicatorInput) =>
      IchimokuCloudSeries(indicatorInput,
          config: this,
          ichimokuCloudOptions: IchimokuCloudOptions(
            baseLinePeriod: baseLinePeriod,
            conversionLinePeriod: conversionLinePeriod,
            leadingSpanBPeriod: spanBPeriod,
          ));

  @override
  IndicatorItem getItem(
    UpdateIndicator updateIndicator,
    VoidCallback deleteIndicator,
  ) =>
      IchimokuCloudIndicatorItem(
        config: this,
        updateIndicator: updateIndicator,
        deleteIndicator: deleteIndicator,
      );
}
