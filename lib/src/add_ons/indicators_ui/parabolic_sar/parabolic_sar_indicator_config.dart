import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/models/parabolic_sar_options.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/parabolic_sar/parabolic_sar_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/theme/painting_styles/scatter_style.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

import '../callbacks.dart';
import '../indicator_config.dart';
import '../indicator_item.dart';
import 'parabolic_sar_indicator_item.dart';

part 'parabolic_sar_indicator_config.g.dart';

/// Parabolic SAR indicator config.
@JsonSerializable()
class ParabolicSARConfig extends IndicatorConfig {
  /// Initializes.
  const ParabolicSARConfig({
    this.minAccelerationFactor = 0.02,
    this.maxAccelerationFactor = 0.2,
    this.scatterStyle = const ScatterStyle(),
    String? title,
    super.number,
  }) : super(title: title ?? ParabolicSARConfig.name);

  /// Initializes from JSON.
  factory ParabolicSARConfig.fromJson(Map<String, dynamic> json) =>
      _$ParabolicSARConfigFromJson(json);

  /// Unique name for this indicator.
  static const String name = 'ParabolicSAR';

  @override
  Map<String, dynamic> toJson() => _$ParabolicSARConfigToJson(this)
    ..putIfAbsent(IndicatorConfig.nameKey, () => name);

  /// Min minAccelerationFactor.
  final double minAccelerationFactor;

  /// Min minAccelerationFactor.
  final double maxAccelerationFactor;

  /// Scatter points style.
  final ScatterStyle scatterStyle;

  @override
  Series getSeries(IndicatorInput indicatorInput) => ParabolicSARSeries(
        indicatorInput,
        ParabolicSAROptions(minAccelerationFactor, maxAccelerationFactor),
        style: scatterStyle,
      );

  @override
  IndicatorItem getItem(
    UpdateIndicator updateIndicator,
    VoidCallback deleteIndicator,
  ) =>
      ParabolicSARIndicatorItem(
        config: this,
        updateIndicator: updateIndicator,
        deleteIndicator: deleteIndicator,
      );

  @override
  ParabolicSARConfig copyWith({
    double? minAccelerationFactor,
    double? maxAccelerationFactor,
    ScatterStyle? scatterStyle,
    String? title,
    int? number,
    bool? showLastIndicator,
    int? pipSize,
  }) {
    return ParabolicSARConfig(
      minAccelerationFactor:
          minAccelerationFactor ?? this.minAccelerationFactor,
      maxAccelerationFactor:
          maxAccelerationFactor ?? this.maxAccelerationFactor,
      scatterStyle: scatterStyle ?? this.scatterStyle,
      title: title ?? this.title,
      number: number ?? this.number,
    );
  }
}
