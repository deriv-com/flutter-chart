import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/models/indicator_options.dart';

/// SMI Options
class SMIOptions extends IndicatorOptions {
  /// Initializes
  const SMIOptions({
    this.period = 10,
    this.smoothingPeriod = 3,
    this.doubleSmoothingPeriod = 3,
  });

  /// Period
  final int period;

  /// Smoothing period
  final int smoothingPeriod;

  /// Double Smoothing period.
  final int doubleSmoothingPeriod;

  @override
  List<Object> get props => <Object>[
        period,
        smoothingPeriod,
        doubleSmoothingPeriod,
      ];
}
