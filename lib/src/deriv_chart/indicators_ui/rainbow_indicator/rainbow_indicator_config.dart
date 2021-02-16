import 'package:deriv_chart/src/deriv_chart/indicators_ui/ma_indicator/ma_indicator_config.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/ma_env_series.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/ma_series.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/models/ma_env_options.dart';
import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';

import '../indicator_config.dart';

/// Moving Average Envelope Indicator Config
class RainbowIndicatorConfig extends MAIndicatorConfig {
  /// Initializes
  const RainbowIndicatorConfig({
    int period,
    MovingAverageType movingAverageType,
    String fieldType,
    this.bandsCount,
  }) : super(period: period, type: movingAverageType, fieldType: fieldType);

  /// Moving Average bands count
  final int bandsCount;

  @override
  Series getSeries(IndicatorInput indicatorInput) => MAEnvSeries.fromIndicator(
      IndicatorConfig.supportedFieldTypes[fieldType](indicatorInput),
      maEnvOptions: MAEnvOptions(
        period: period,
        movingAverageType: type,
      ));
}
