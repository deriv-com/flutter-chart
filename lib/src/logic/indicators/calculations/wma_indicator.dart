import 'package:deriv_chart/src/logic/indicators/indicator.dart';
import 'package:deriv_chart/src/models/tick.dart';

import '../cached_indicator.dart';

/// Weighted Moving Average indicator
class WMAIndicator extends CachedIndicator {
  /// Initializes
  WMAIndicator(this.indicator, this.period) : super.fromIndicator(indicator);

  /// Bar count
  final int period;

  /// Indicator
  final Indicator indicator;

  @override
  Tick calculate(int index) {
    if (index == 0) {
      return indicator.getValue(0);
    }
    double value = 0;
    if (index - period < 0) {
      for (int i = index + 1; i > 0; i--) {
        value = value + (i * (indicator.getValue(i - 1).quote));
      }

      return Tick(
        epoch: getEpochOfIndex(index),
        quote: value / (((index + 1) * (index + 2)) / 2),
      );
    }

    int actualIndex = index;

    for (int i = period; i > 0; i--) {
      value = value + (i * (indicator.getValue(actualIndex).quote));
      actualIndex--;
    }

    return Tick(
      epoch: getEpochOfIndex(index),
      quote: value / ((period * (period + 1)) / 2),
    );
  }
}
