import 'package:deriv_chart/src/models/tick.dart';

import '../indicator.dart';
import 'recursive_cached_indicator.dart';
import 'sma_indicator.dart';

class ZLEMAIndicator extends RecursiveCachedIndicator {
  final Indicator indicator;
  final int barCount;
  final double k;
  final int lag;

  ZLEMAIndicator(this.indicator, this.barCount)
      : k = 2 / (barCount + 1),
        lag = (barCount - 1) ~/ 2,
        super.fromIndicator(indicator);

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
      quote: (k *
              ((2 * (indicator.getValue(index).quote)) -
                  (indicator.getValue(index - lag).quote))) +
          ((1 - k) * zlemaPrev),
    );
  }
}
