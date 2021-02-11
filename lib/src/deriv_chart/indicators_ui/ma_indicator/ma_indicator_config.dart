import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/ma_series.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/models/indicator_options.dart';

import '../indicator_config.dart';

/// Moving Average indicator config
class MAIndicatorConfig extends IndicatorConfig {
  /// Initializes
  const MAIndicatorConfig({
    this.period,
    this.type,
    this.fieldType,
    this.lineStyle,
  }) : super();

  /// Moving Average period
  final int period;

  /// Moving Average type
  final MovingAverageType type;

  /// Field type
  final String fieldType;

  /// MA line style
  final LineStyle lineStyle;

  @override
  Series getSeries(List<Tick> ticks) => MASeries.fromIndicator(
        IndicatorConfig.supportedFieldTypes[fieldType](ticks),
        style: lineStyle,
        options: MAOptions(period: period, type: type),
      );
}
