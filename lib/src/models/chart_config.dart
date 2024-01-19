import 'package:deriv_chart/deriv_chart.dart';
import 'package:flutter/material.dart';

/// Chart's general configuration.
@immutable
class ChartConfig {
  /// Initializes chart's general configuration.
  const ChartConfig({
    required this.granularity,
    this.chartAxisConfig = const ChartAxisConfig(),
    this.pipSize = 4,
  });

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
