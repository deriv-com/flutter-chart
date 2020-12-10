import 'package:deriv_chart/src/logic/chart_series/indicators_series/ma_series.dart';

import '../callbacks.dart';
import '../indicator_config.dart';

/// Moving Average indicator config
class MAIndicatorConfig extends IndicatorConfig {
  /// Initializes
  const MAIndicatorConfig(
    IndicatorBuilder indicatorBuilder, {
    this.period,
    this.type,
    this.fieldType,
  }) : super(indicatorBuilder);

  /// Moving Average period
  final int period;

  /// Moving Average type
  final MovingAverageType type;

  /// Field type
  final String fieldType;
}
