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
        _highValueIndicator = HighValueIndicator<T>(input),
        _lowValueIndicator = LowValueIndicator<T>(input),
        _period = period,
        super(input);

  final int _period;

  final HighValueIndicator<T> _highValueIndicator;
  final LowValueIndicator<T> _lowValueIndicator;
  final Indicator<T> _indicator;

  @override
  T calculate(int index) {
    final HighestValueIndicator<T> highestHigh =
        HighestValueIndicator<T>(_highValueIndicator, _period);
    final LowestValueIndicator<T> lowestLow =
        LowestValueIndicator<T>(_lowValueIndicator, _period);

    final double highestHighQuote = highestHigh.getValue(index).quote;
    final double lowestLowQuote = lowestLow.getValue(index).quote;

    final double kPercent =
        ((_indicator.getValue(index).quote - lowestLowQuote) /
                (highestHighQuote - lowestLowQuote)) *
            100;

    return createResult(index: index, quote: kPercent);
  }
}
