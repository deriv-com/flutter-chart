import 'package:flutter/foundation.dart';

/// Chart's general configuration.
@immutable
class ChartConfig {
  /// Initializes
  const ChartConfig({this.pipSize, this.granularity});

  /// PipSize, number of decimal digits when showing prices on the chart
  final int pipSize;

  /// Granularity
  final int granularity;

  @override
  bool operator ==(covariant ChartConfig other) =>
      pipSize == other.pipSize && granularity == other.granularity;

  @override
  int get hashCode => super.hashCode;
}
