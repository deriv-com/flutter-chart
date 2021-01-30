import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';

import '../cached_indicator.dart';
import '../indicator.dart';
import 'sma_indicator.dart';

/// Zero-lag Exponential Moving Average indicator
class ZLEMAIndicator<T extends Result> extends CachedIndicator<T> {
  /// Initializes
  ///
  /// [indicator] An indicator
  ///
  /// [period] Bar count.
  ZLEMAIndicator(this.indicator, this.period)
      : _k = 2 / (period + 1),
        _lag = (period - 1) ~/ 2,
        super.fromIndicator(indicator);

  /// Indicator to calculate ZELMA on
  final Indicator<T> indicator;

  /// Bar count
  final int period;

  final double _k;
  final int _lag;

  @override
  T calculate(int index) {
    if (index + 1 < period) {
      // Starting point of the ZLEMA
      return SMAIndicator<T>(indicator, period).getValue(index);
    }
    if (index == 0) {
      // If the period is bigger than the indicator's value count
      return indicator.getValue(0);
    }

    final double prevZlema = getValue(index - 1).quote;

    return createResult(
      index: index,
      quote: (_k *
              ((2 * (indicator.getValue(index).quote)) -
                  (indicator.getValue(index - _lag).quote))) +
          ((1 - _k) * prevZlema),
    );
  }
}
