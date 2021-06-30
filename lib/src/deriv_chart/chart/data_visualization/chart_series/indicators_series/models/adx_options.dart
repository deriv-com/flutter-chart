import 'indicator_options.dart';

/// ADX Options.
class ADXOptions extends IndicatorOptions {
  ///Initializes an ADX Options.
  const ADXOptions({
    this.period = 14,
    this.smoothingPeriod = 14,
  });

  /// The period value for the ADX series.
  final int period;

  /// The period value for smoothing the ADX series.
  final int smoothingPeriod;

  @override
  List<int> get props => <int>[period, smoothingPeriod];
}
