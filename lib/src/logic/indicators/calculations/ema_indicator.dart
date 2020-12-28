import 'package:deriv_chart/src/models/tick.dart';

import '../indicator.dart';
import '../cached_indicator.dart';

/// Base class for Exponential Moving Average implementations.
abstract class AbstractEMAIndicator extends CachedIndicator<Tick> {
  /// Initializes
  AbstractEMAIndicator(this.indicator, this.period, this.multiplier)
      : super.fromIndicator(indicator);

  /// Indicator to calculate EMA on.
  final Indicator<Tick> indicator;

  /// Bar count
  final int period;

  /// Multiplier
  final double multiplier;

  @override
  Tick calculate(int index) {
    if (index == 0) {
      return indicator.getValue(0);
    }

    final double prevValue = getValue(index - 1).quote;
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
  EMAIndicator(Indicator<Tick> indicator, int period)
      : super(indicator, period, 2.0 / (period + 1));
}
