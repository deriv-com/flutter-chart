import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';
import 'package:deriv_technical_analysis/src/indicators/calculations/stochastic/fast_stochastic_indicator.dart';

/// %D also known as the Slow Stochatic Indicator.
/// It is a 3-period moving average of %K.
class SlowStochasticIndicator<T extends IndicatorResult>
    extends CachedIndicator<T> {
  /// Initializes a Slow Stochatic Indicator.
  SlowStochasticIndicator(
    IndicatorDataInput input, {
    FastStochasticIndicator<T> stochasticIndicator,
  })  : _stochasticOscillatorDIndicator = SMAIndicator<T>(
            stochasticIndicator ?? FastStochasticIndicator<T>(input), 3),
        super(input);

  final SMAIndicator<T> _stochasticOscillatorDIndicator;

  @override
  T calculate(int index) => createResult(
      index: index,
      quote: _stochasticOscillatorDIndicator.getValue(index).quote);
}
