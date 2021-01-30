import 'package:deriv_technical_analysis/src/models/models.dart';

import '../cached_indicator.dart';
import '../indicator.dart';

/// Base class for Exponential Moving Average implementations.
abstract class AbstractEMAIndicator<T extends Result>
    extends CachedIndicator<T> {
  /// Initializes
  AbstractEMAIndicator(this.indicator, this.period, this.multiplier)
      : super.fromIndicator(indicator);

  /// Indicator to calculate EMA on.
  final Indicator<T> indicator;

  /// Bar count
  final int period;

  /// Multiplier
  final double multiplier;

  @override
  T calculate(int index) {
    if (index == 0) {
      return indicator.getValue(0);
    }

    final double prevValue = getValue(index - 1).quote;
    return createResult(
      index: index,
      quote: ((indicator.getValue(index).quote - prevValue) * multiplier) +
          prevValue,
    );
  }
}

/// EMA indicator
class EMAIndicator<T extends Result> extends AbstractEMAIndicator<T> {
  /// Initializes
  EMAIndicator(Indicator<T> indicator, int period)
      : super(indicator, period, 2.0 / (period + 1));
}
