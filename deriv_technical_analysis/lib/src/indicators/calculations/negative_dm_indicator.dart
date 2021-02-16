import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';

/// Negative Directional Movement indicator.
class NegativeDMIndicator<T extends IndicatorResult>
    extends CachedIndicator<T> {
  ///Intializes a Negative Directional Movement indicator.
  NegativeDMIndicator(IndicatorDataInput input) : super(input);

  @override
  T calculate(int index) {
    final T zeroResult = createResult(index: index, quote: 0);
    if (index == 0) {
      return zeroResult;
    }
    final IndicatorOHLC prevTick = entries[index - 1];
    final IndicatorOHLC currentTick = entries[index];

    final double upMove = currentTick.high - prevTick.high;
    final double downMove = prevTick.low - currentTick.low;
    if (downMove > upMove && downMove > 0) {
      return createResult(index: index, quote: downMove);
    } else {
      return zeroResult;
    }
  }
}
