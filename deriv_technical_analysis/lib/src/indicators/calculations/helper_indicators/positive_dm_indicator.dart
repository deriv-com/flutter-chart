import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';

/// Positive Directional Movement indicator.
class PositiveDMIndicator<T extends IndicatorResult>
    extends CachedIndicator<T> {
  /// Initializes a Positive Directional Movement indicator.
  PositiveDMIndicator(IndicatorDataInput input) : super(input);

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
    if (upMove > downMove && upMove > 0) {
      return createResult(index: index, quote: upMove);
    } else {
      return zeroResult;
    }
  }
}
