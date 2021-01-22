import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/indicators_ui/indicator_config.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/donchian_channels_indicator_series.dart';
import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/models/tick.dart';

/// Bollinger Bands Indicator Config
class DonchianChannelIndicatorConfig extends IndicatorConfig {
  /// Initializes
  const DonchianChannelIndicatorConfig({
    this.highPeriod,
    this.lowPeriod,
    this.showChannelFill,
  }) : super();

  // TODO: Add doc
  final int highPeriod;

  /// Number of last candles used to calculate lowest value.
  final int lowPeriod;

  /// Whether the area between upper and lower channel is filled.
  final bool showChannelFill;

  @override
  Series getSeries(List<Tick> ticks) =>
      DonchianChannelsIndicatorSeries.fromIndicator(
        IndicatorConfig.supportedFieldTypes['high'](ticks),
        IndicatorConfig.supportedFieldTypes['low'](ticks),
        this,
      );
}
