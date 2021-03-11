import 'package:deriv_chart/src/logic/chart_series/indicators_series/ma_series.dart';
import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/models/indicator_options.dart';
import 'package:json_annotation/json_annotation.dart';

import '../indicator_config.dart';

part 'ma_indicator_config.g.dart';

/// Moving Average indicator config
@JsonSerializable()
class MAIndicatorConfig extends IndicatorConfig {
  /// Initializes
  const MAIndicatorConfig({
    this.period,
    this.type,
    this.fieldType,
    this.lineStyle,
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
  final MovingAverageType type;

  /// Field type
  final String fieldType;

  /// MA line style
  final LineStyle lineStyle;

  @override
  Series getSeries(IndicatorInput indicatorInput) => MASeries.fromIndicator(
        IndicatorConfig.supportedFieldTypes[fieldType](indicatorInput),
        options: MAOptions(period: period, type: type),
        style: lineStyle,
      );
}
