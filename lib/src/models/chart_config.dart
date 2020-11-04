import 'package:deriv_chart/deriv_chart.dart';

/// Chart's general configuration.
class ChartConfig {
  /// Initializes
  const ChartConfig({
    this.pipSize,
    this.granularity,
    this.theme,
  });

  /// PipSize, number of decimal digits when showing prices on the chart
  final int pipSize;

  /// Granularity
  final int granularity;

  /// Chart theme
  final ChartTheme theme;
}
