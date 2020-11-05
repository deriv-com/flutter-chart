/// Chart's general configuration.
class ChartConfig {
  /// Initializes
  const ChartConfig({this.pipSize, this.granularity});

  /// PipSize, number of decimal digits when showing prices on the chart
  final int pipSize;

  /// Granularity
  final int granularity;
}
