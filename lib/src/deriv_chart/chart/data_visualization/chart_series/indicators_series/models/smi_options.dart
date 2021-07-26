import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/ma_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/models/indicator_options.dart';

/// SMI Options
class SMIOptions extends IndicatorOptions {
  /// Initializes
  const SMIOptions({
    this.period = 10,
    this.smoothingPeriod = 3,
    this.doubleSmoothingPeriod = 3,
    this.signalOptions = const MAOptions(
      period: 10,
      type: MovingAverageType.exponential,
    ),
  });

  /// Period
  final int period;

  /// Smoothing period
  final int smoothingPeriod;

  /// Double Smoothing period.
  final int doubleSmoothingPeriod;

  /// SMI signal options.
  final MAOptions signalOptions;

  @override
  List<Object> get props => <Object>[
        period,
        smoothingPeriod,
        doubleSmoothingPeriod,
        signalOptions,
      ];
}
