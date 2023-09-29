import 'package:deriv_chart/deriv_chart.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chart_config.g.dart';

/// Chart's general configuration.
@immutable
@JsonSerializable()
class ChartConfig {
  /// Initializes chart's general configuration.
  const ChartConfig({
    required this.granularity,
    this.chartAxisConfig = const ChartAxisConfig(),
    this.pipSize = 4,
  });

  /// Initializes from JSON.
  factory ChartConfig.fromJson(Map<String, dynamic> json) =>
      _$ChartConfigFromJson(json);

  /// Serialization to JSON. Serves as value in key-value storage.
  Map<String, dynamic> toJson() => _$ChartConfigToJson(this);

  /// PipSize, number of decimal digits when showing prices on the chart.
  final int pipSize;

  /// Granularity.
  final int granularity;

  /// Chart Axis configuration.
  final ChartAxisConfig chartAxisConfig;

  @override
  bool operator ==(covariant ChartConfig other) =>
      pipSize == other.pipSize && granularity == other.granularity;

  @override
  int get hashCode => Object.hash(pipSize, granularity);
}
