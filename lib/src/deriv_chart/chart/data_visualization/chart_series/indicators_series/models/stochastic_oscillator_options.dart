import 'package:deriv_chart/src/logic/chart_series/indicators_series/models/indicator_options.dart';

/// StochasticOscillator indicator options.
class StochasticOscillatorOptions extends IndicatorOptions {
  /// Initializes an StochasticOscillator indicator options.
  const StochasticOscillatorOptions(
      {this.period = 14, this.isSmooth = true, this.showZones = true});

  /// The period to calculate Stochastic Oscillator Indicator on.
  final int period;

  /// if StochasticOscillator is smooth
  /// default is true
  final bool isSmooth;

  /// if show the overbought and oversold zones
  /// default is false
  final bool showZones;

  @override
  List<Object> get props => <Object>[period, isSmooth, showZones];
}
