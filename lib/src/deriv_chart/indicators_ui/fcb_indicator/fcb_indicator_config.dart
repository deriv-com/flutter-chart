import 'package:deriv_chart/src/logic/chart_series/indicators_series/fcb_series.dart';
import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';

import '../indicator_config.dart';

/// Fractal Chaos Band Indicator Config
class FractalChaosBandIndicatorConfig extends IndicatorConfig {
  /// Initializes
  const FractalChaosBandIndicatorConfig({this.channelFill}) : super();

  /// if it's true the channel between two lines will be filled
  final bool channelFill;

  @override
  Series getSeries(IndicatorInput indicatorInput) =>
      FractalChaosBandSeries(indicatorInput,
         channelFill: channelFill);
}
