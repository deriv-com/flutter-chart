import 'indicator_options.dart';

/// RSI indicator options.
class RSIOptions extends IndicatorOptions {
  /// Initializes an RSI indicator options.
  const RSIOptions({this.period = 14});

  /// The period to calculate rsi Indicator on.
  final int period;

  @override
  List<Object> get props => <Object>[period];
}
