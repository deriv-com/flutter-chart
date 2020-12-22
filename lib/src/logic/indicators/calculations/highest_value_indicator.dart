import 'dart:math';

import 'package:deriv_chart/src/models/tick.dart';

import '../indicator.dart';
import '../cached_indicator.dart';

/// Highest value indicator
class HighestValueIndicator extends CachedIndicator {
  /// Initializes
  HighestValueIndicator(this.indicator, this.period)
      : super.fromIndicator(indicator);

  /// Calculate Highest value on the result of this indicator
  final Indicator indicator;

  /// Number of elements to calculate from
  final int period;

  @override
  Tick calculate(int index) {
    if (indicator.getValue(index).quote.isNaN && period != 1) {
      return HighestValueIndicator(indicator, period - 1).getValue(index - 1);
    }

    final int end = max(0, index - period + 1);
    double highest = indicator.getValue(index).quote;

    for (int i = index - 1; i >= end; i--) {
      if (highest < getValue(i).quote) {
        highest = indicator.getValue(i).quote;
      }
    }

    return Tick(epoch: getEpochOfIndex(index), quote: highest);
  }
}
