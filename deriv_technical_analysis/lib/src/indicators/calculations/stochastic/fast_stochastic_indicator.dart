import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';

/// %K also known as the Fast Stochatic Indicator.
/// A stochastic oscillator is a popular technical indicator for generating overbought and oversold signals.
class FastStochasticIndicator<T extends IndicatorResult>
    extends CachedIndicator<T> {
  /// Initiaizes a Fast Stochatic Indicator.
  FastStochasticIndicator(
    IndicatorDataInput input, {
    CloseValueIndicator<T> indicator,
    int period = 14,
  })  : _indicator = indicator ?? CloseValueIndicator<T>(input),
        _highestValueIndicator =
            HighestValueIndicator<T>(HighValueIndicator<T>(input), period),
        _lowestValueIndicator =
            LowestValueIndicator<T>(LowValueIndicator<T>(input), period),
        super(input);

  final HighestValueIndicator<T> _highestValueIndicator;
  final LowestValueIndicator<T> _lowestValueIndicator;
  final Indicator<T> _indicator;

  @override
  T calculate(int index) {
    final double highestHighQuote =
        _highestValueIndicator.getValue(index).quote;
    final double lowestLowQuote = _lowestValueIndicator.getValue(index).quote;

    final double kPercent =
        ((_indicator.getValue(index).quote - lowestLowQuote) /
                (highestHighQuote - lowestLowQuote)) *
            100;

    return createResult(index: index, quote: kPercent);
  }
}
