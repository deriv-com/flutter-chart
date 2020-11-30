import 'package:deriv_chart/src/logic/chart_series/indicators_series/ma_series.dart';

import '../callbacks.dart';
import '../indicator_config.dart';

/// Moving Average indicator config
class BollingerBandsIndicatorConfig extends IndicatorConfig {
  /// Initializes
  const BollingerBandsIndicatorConfig(
    IndicatorBuilder indicatorBuilder, {
    this.period,
    this.movingAverageType,
    this.standardDeviation,
  }) : super(indicatorBuilder);

  /// Moving Average period
  final int period;

  /// Moving Average type
  final MovingAverageType movingAverageType;

  /// Standard Deviation value
  final double standardDeviation;
}
