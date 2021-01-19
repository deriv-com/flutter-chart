import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/zigzag_series.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/helper_indicators/close_value_inidicator.dart';

import '../indicator_config.dart';

/// Moving Average indicator config
class ZigZagIndicatorConfig extends IndicatorConfig {
  /// Initializes
  const ZigZagIndicatorConfig({
    this.distance,
    this.lineStyle,
  }) : super();

  /// ZigZag period
  final int distance;


  /// ZigZag line style
  final LineStyle lineStyle;

  @override
  Series getSeries(List<Tick> ticks) => ZigZagSeries.fromIndicator(
    CloseValueIndicator(ticks),
        distance: distance,
        style: lineStyle,
      );
}
