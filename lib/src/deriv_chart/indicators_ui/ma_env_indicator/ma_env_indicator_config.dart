import 'package:deriv_chart/src/deriv_chart/indicators_ui/indicator_config.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/ma_env_series.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/ma_series.dart';
import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/models/tick.dart';

import '../../../../deriv_chart.dart';

/// Moving Average Envelope Indicator Config
class MAEnvIndicatorConfig extends IndicatorConfig {
  /// Initializes
  const MAEnvIndicatorConfig({
    this.period,
    this.movingAverageType,
    this.fieldType,
    this.shift,
    this.shiftType,
    this.lineStyle,
  }) : super();

  /// Moving Average period
  final int period;

  /// Moving Average type
  final MovingAverageType movingAverageType;

  /// Field type
  final String fieldType;

  /// Shift type
  final ShiftType shiftType;

  /// Moving Average Envelope shift
  final int shift;

  /// MA line style
  final LineStyle lineStyle;

  @override
  Series getSeries(List<Tick> ticks) => MAEnvSeries.fromIndicator(
        IndicatorConfig.supportedFieldTypes[fieldType](ticks),
        period: period,
        movingAverageType: movingAverageType,
        shift: shift,
        shiftType: shiftType,
        style: lineStyle,
      );
}
