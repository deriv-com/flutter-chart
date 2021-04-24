/// Chart's general configuration.

// @dart=2.9

class ChartConfig {
  /// Initializes chart's general configuration.
  const ChartConfig({this.pipSize, this.granularity});

  /// PipSize, number of decimal digits when showing prices on the chart.
  final int pipSize;

  /// Granularity.
  final int granularity;

  @override
  bool operator ==(covariant ChartConfig other) =>
      pipSize == other.pipSize && granularity == other.granularity;

  @override
  int get hashCode => super.hashCode;
}
