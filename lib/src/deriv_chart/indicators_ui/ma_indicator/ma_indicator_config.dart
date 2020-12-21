import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/indicators_ui/callbacks.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/ma_series.dart';

import '../indicator_config.dart';

/// Moving Average indicator config
class MAIndicatorConfig extends IndicatorConfig {
  /// Initializes
  MAIndicatorConfig({
    this.period,
    this.type,
    this.fieldType,
    this.lineStyle,
    this.feildIndicatorBuilder,
  }) : super();

  /// Moving Average period
  final int period;

  /// Moving Average type
  final MovingAverageType type;

  /// Field type
  final String fieldType;

  /// MA line style
  final LineStyle lineStyle;

  final Map<String, FieldIndicatorBuilder> feildIndicatorBuilder;

  @override
  Series getSeries(List<Tick> ticks) => MASeries.fromIndicator(
        feildIndicatorBuilder[fieldType](ticks),
        period: period,
        type: type,
        style: lineStyle,
      );
}
