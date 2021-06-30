import 'indicator_options.dart';

/// ADX Options.
class ADXOptions extends IndicatorOptions {
  ///Initializes an ADX Options.
  const ADXOptions({
    this.period = 14,
    this.smoothingPeriod = 14,
  });

  /// The `period` for the `ADXIndicator` and the `Positive/NegativeDIIndicator`s. Default is set to `14`.
  final int period;

  /// The `period` for the smoothing the `ADXIndicator` results. Default is set to `14`.
  final int smoothingPeriod;

  @override
  List<int> get props => <int>[period, smoothingPeriod];
}
