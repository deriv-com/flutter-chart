import 'package:deriv_chart/src/deriv_chart/indicators_ui/ma_indicator/ma_indicator_config.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/ma_series.dart';

import '../callbacks.dart';

/// Bollinger Bands Indicator Config
class BollingerBandsIndicatorConfig extends MAIndicatorConfig {
  /// Initializes
  const BollingerBandsIndicatorConfig(
    IndicatorBuilder indicatorBuilder, {
    int period,
    MovingAverageType movingAverageType,
    String fieldType,
    this.standardDeviation,
  }) : super(
          indicatorBuilder,
          period: period,
          type: movingAverageType,
          fieldType: fieldType,
        );

  /// Standard Deviation value
  final double standardDeviation;
}
