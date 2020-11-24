import 'package:deriv_chart/src/models/tick.dart';

import '../indicator.dart';
import 'recursive_cached_indicator.dart';

/// Base class for Exponential Moving Average implementations.
abstract class AbstractEMAIndicator extends RecursiveCachedIndicator {
  AbstractEMAIndicator(this.indicator, this.barCount, this.multiplier)
      : super.fromIndicator(indicator);

  /// Indicator to calculate EMA on.
  final Indicator indicator;

  /// Bar count
  final int barCount;

  /// Multiplier
  final double multiplier;

  @override
  Tick calculate(int index) {
    if (index == 0) {
      return indicator.getValue(0);
    }
    double prevValue = getValue(index - 1).quote;
    return Tick(
      epoch: getEpochOfIndex(index),
      quote: ((indicator.getValue(index).quote - prevValue) * multiplier) +
          prevValue,
    );
  }
}

/// EMA indicator
class EMAIndicator extends AbstractEMAIndicator {
  /// Initializes
  EMAIndicator(Indicator indicator, int barCount)
      : super(indicator, barCount, (2.0 / (barCount + 1)));
}
