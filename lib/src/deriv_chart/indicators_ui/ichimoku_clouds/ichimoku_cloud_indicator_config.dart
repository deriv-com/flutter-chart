import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/indicators_ui/indicator_config.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/ichimoku_cloud_series.dart';

/// Ichimoku Cloud Indicator Config
class IchimokuCloudIndicatorConfig extends IndicatorConfig {
  /// Initializes
  const IchimokuCloudIndicatorConfig() : super();

  @override
  Series getSeries(List<Tick> ticks) => IchimokuCloudSeries(ticks);
}
