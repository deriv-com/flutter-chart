import 'package:deriv_chart/src/deriv_chart/indicators_ui/indicator_config.dart';
import 'package:deriv_chart/src/deriv_chart/indicators_ui/ma_indicator/ma_indicator_config.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/bollinger_bands_series.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/ma_series.dart';
import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';

/// Bollinger Bands Indicator Config
class BollingerBandsIndicatorConfig extends MAIndicatorConfig {
  /// Initializes
  const BollingerBandsIndicatorConfig({
    int period,
    MovingAverageType movingAverageType,
    String fieldType,
    this.standardDeviation,
  }) : super(
          period: period,
          type: movingAverageType,
          fieldType: fieldType,
        );

  /// Standard Deviation value
  final double standardDeviation;

  @override
  Series getSeries(IndicatorInput indicatorInput) =>
      BollingerBandSeries.fromIndicator(
        IndicatorConfig.supportedFieldTypes[fieldType](indicatorInput),
        period: period,
        movingAverageType: type,
        standardDeviationFactor: standardDeviation,
      );
}
