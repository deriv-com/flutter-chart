import 'package:deriv_chart/src/deriv_chart/indicators_ui/ma_indicator/ma_indicator_config.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/ma_env_series.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/ma_series.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/models/ma_env_options.dart';
import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';

import '../indicator_config.dart';

/// Moving Average Envelope Indicator Config
class MAEnvIndicatorConfig extends MAIndicatorConfig {
  /// Initializes
  const MAEnvIndicatorConfig({
    int period,
    String movingAverageType,
    String fieldType,
    this.shift,
    this.shiftType,
  }) : super(period: period, type: movingAverageType, fieldType: fieldType);

  /// Moving Average Envelope shift type
  final ShiftType shiftType;

  /// Moving Average Envelope shift
  final double shift;

  @override
  Series getSeries(IndicatorInput indicatorInput) => MAEnvSeries.fromIndicator(
      IndicatorConfig.supportedFieldTypes[fieldType](indicatorInput),
      maEnvOptions: MAEnvOptions(
        period: period,
        movingAverageType: type,
        shift: shift,
        shiftType: shiftType,
      ));
}
