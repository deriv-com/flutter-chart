import 'indicator_options.dart';

/// PSAR options
class WilliamsROptions extends IndicatorOptions {
  /// Initializes
  const WilliamsROptions(this.period);

  /// Period
  final int period;

  @override
  List<Object> get props => <Object>[period];
}
