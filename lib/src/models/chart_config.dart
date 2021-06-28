import 'package:flutter/material.dart';

/// Chart's general configuration.
@immutable
class ChartConfig {
  /// Initializes chart's general configuration.
  const ChartConfig({required this.granularity, this.pipSize = 4});

  /// PipSize, number of decimal digits when showing prices on the chart.
  final int pipSize;

  /// Granularity.
  final int granularity;

  @override
  bool operator ==(covariant ChartConfig other) =>
      pipSize == other.pipSize && granularity == other.granularity;

  @override
  int get hashCode => hashValues(pipSize, granularity);
}
