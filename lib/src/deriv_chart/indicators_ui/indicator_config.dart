import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/models/tick.dart';

/// Indicator config
abstract class IndicatorConfig {
  /// Initializes
  IndicatorConfig();

  Series getSeries(List<Tick> ticks);
}
