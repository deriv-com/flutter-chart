import 'package:deriv_chart/src/logic/chart_series/indicators_series/models/parabolic_sar_options.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/parabolic_sar/parabolic_sar_series.dart';
import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';

import '../indicator_config.dart';

/// Moving Average indicator config
class ParabolicSARConfig extends IndicatorConfig {
  /// Initializes
  const ParabolicSARConfig({
    this.minAccelerationFactor,
    this.maxAccelerationFactor,
    this.lineStyle,
  }) : super();

  /// Min minAccelerationFactor
  final double minAccelerationFactor;

  /// Min minAccelerationFactor
  final double maxAccelerationFactor;

  /// MA line style
  final LineStyle lineStyle;

  @override
  Series getSeries(IndicatorInput indicatorInput) => ParabolicSARSeries(
        indicatorInput,
        ParabolicSAROptions(minAccelerationFactor, maxAccelerationFactor),
      );
}
