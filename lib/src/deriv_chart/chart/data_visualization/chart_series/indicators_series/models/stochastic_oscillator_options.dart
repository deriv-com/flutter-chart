import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/models/indicator_options.dart';

/// StochasticOscillator indicator options.
class StochasticOscillatorOptions extends IndicatorOptions {
  /// Initializes an StochasticOscillator indicator options.
  const StochasticOscillatorOptions({
    this.period = 14,
    this.isSmooth = true,
    bool showLastIndicator = false,
    int pipSize = 4,
  }) : super(
          showLastIndicator: showLastIndicator,
          pipSize: pipSize,
        );

  /// The period to calculate Stochastic Oscillator Indicator on.
  final int period;

  /// if StochasticOscillator is smooth
  /// default is true
  final bool isSmooth;

  @override
  List<Object> get props => <Object>[period, isSmooth];
}
