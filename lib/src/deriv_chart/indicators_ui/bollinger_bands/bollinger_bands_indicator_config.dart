import 'package:deriv_chart/src/deriv_chart/indicators_ui/callbacks.dart';
import 'package:deriv_chart/src/deriv_chart/indicators_ui/ma_indicator/ma_indicator_config.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/bollinger_bands_series.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/ma_series.dart';
import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/models/tick.dart';

/// Bollinger Bands Indicator Config
class BollingerBandsIndicatorConfig extends MAIndicatorConfig {
  /// Initializes
  BollingerBandsIndicatorConfig({
    int period,
    MovingAverageType movingAverageType,
    String fieldType,
    Map<String, FieldIndicatorBuilder> feildIndicatorBuilder,
    this.standardDeviation,
  }) : super(
          period: period,
          type: movingAverageType,
          fieldType: fieldType,
          feildIndicatorBuilder: feildIndicatorBuilder,
        );

  /// Standard Deviation value
  final double standardDeviation;

  @override
  Series getSeries(List<Tick> ticks) => BollingerBandSeries.fromIndicator(
        feildIndicatorBuilder[fieldType](ticks),
        period: period,
        movingAverageType: type,
        standardDeviationFactor: standardDeviation,
      );
}
