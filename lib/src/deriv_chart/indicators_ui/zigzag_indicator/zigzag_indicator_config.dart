import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/zigzag_series.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';

import '../indicator_config.dart';

/// ZigZag indicator config
class ZigZagIndicatorConfig extends IndicatorConfig {
  /// Initializes
  const ZigZagIndicatorConfig({
    this.distance,
    this.lineStyle,
  }) : super();

  /// ZigZag distance in %
  final double distance;

  /// ZigZag line style
  final LineStyle lineStyle;

  @override
  Series getSeries(IndicatorInput indicatorInput) => ZigZagSeries(
        indicatorInput,
        distance: distance,
        style: lineStyle,
      );
}
