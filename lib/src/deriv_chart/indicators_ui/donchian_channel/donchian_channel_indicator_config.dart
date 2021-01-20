import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/indicators_ui/indicator_config.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/bollinger_bands_series.dart';
import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/models/tick.dart';

/// Bollinger Bands Indicator Config
class DonchianChannelIndicatorConfig extends IndicatorConfig {
  /// Initializes
  const DonchianChannelIndicatorConfig({
    this.highPeriod,
    this.lowPeriod,
  }) : super();

  // TODO: Add doc
  final int highPeriod;

  // TODO: Add doc
  final int lowPeriod;

  @override
  // TODO: Replace with donchian series
  Series getSeries(List<Tick> ticks) => BollingerBandSeries.fromIndicator(
        IndicatorConfig.supportedFieldTypes['close'](ticks),
        period: 10,
        movingAverageType: MovingAverageType.simple,
        standardDeviationFactor: 2,
      );
}
