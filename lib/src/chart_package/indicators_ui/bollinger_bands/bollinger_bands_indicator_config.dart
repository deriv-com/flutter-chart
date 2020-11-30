import 'package:deriv_chart/src/chart_package/indicators_ui/ma_indicator/ma_indicator_config.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/ma_series.dart';

import '../callbacks.dart';

/// Moving Average indicator config
class BollingerBandsIndicatorConfig extends MAIndicatorConfig {
  /// Initializes
  const BollingerBandsIndicatorConfig(
    IndicatorBuilder indicatorBuilder, {
    int period,
    MovingAverageType movingAverageType,
    this.standardDeviation,
  }) : super(indicatorBuilder, period: period, type: movingAverageType);

  /// Standard Deviation value
  final double standardDeviation;
}
