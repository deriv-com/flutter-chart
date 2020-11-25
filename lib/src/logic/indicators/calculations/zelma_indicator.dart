import 'package:deriv_chart/src/models/tick.dart';

import '../indicator.dart';
import '../cached_indicator.dart';
import 'sma_indicator.dart';

/// Zero-lag Exponential Moving Average indicator
class ZLEMAIndicator extends CachedIndicator {
  /// Initializes
  ///
  /// [indicator] An indicator
  ///
  /// [barCount] Bar count.
  ZLEMAIndicator(this.indicator, this.barCount)
      : _k = 2 / (barCount + 1),
        _lag = (barCount - 1) ~/ 2,
        super.fromIndicator(indicator);

  /// Indicator to calculate ZELMA on
  final Indicator indicator;

  /// Bar count
  final int barCount;

  final double _k;
  final int _lag;

  @override
  Tick calculate(int index) {
    if (index + 1 < barCount) {
      // Starting point of the ZLEMA
      return SMAIndicator(indicator, barCount).getValue(index);
    }
    if (index == 0) {
      // If the barCount is bigger than the indicator's value count
      return indicator.getValue(0);
    }

    double zlemaPrev = getValue(index - 1).quote;

    return Tick(
      epoch: getEpochOfIndex(index),
      quote: (_k *
              ((2 * (indicator.getValue(index).quote)) -
                  (indicator.getValue(index - _lag).quote))) +
          ((1 - _k) * zlemaPrev),
    );
  }
}
