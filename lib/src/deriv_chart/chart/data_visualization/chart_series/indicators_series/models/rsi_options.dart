import 'indicator_options.dart';

/// RSI indicator options.
class RSIOptions extends IndicatorOptions {
  /// Initializes an RSI indicator options.
  const RSIOptions({
    this.period = 14,
    bool showLastIndicator = false,
    int pipSize = 4,
  }) : super(
          pipSize: pipSize,
          showLastIndicator: showLastIndicator,
        );

  /// The period to calculate rsi Indicator on.
  final int period;

  @override
  List<Object> get props => <Object>[period];
}
