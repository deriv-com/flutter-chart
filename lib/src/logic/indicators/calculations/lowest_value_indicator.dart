import 'dart:math';

import 'package:deriv_chart/src/models/tick.dart';

import '../indicator.dart';
import '../cached_indicator.dart';

/// Lowest price in a range
class LowestValueIndicator extends CachedIndicator {
  /// Initializes
  LowestValueIndicator(this.indicator, this.period)
      : super(indicator.entries);

  /// Indicator to calculate Lowest value on
  final Indicator indicator;

  /// Bar count
  final int period;

  @override
  Tick calculate(int index) {
    if (indicator.getValue(index).quote.isNaN && period != 1) {
      return LowestValueIndicator(indicator, period - 1).getValue(index - 1);
    }

    final int end = max(0, index - period + 1);
    double lowest = indicator.getValue(index).quote;

    for (int i = index - 1; i >= end; i--) {
      if (lowest > indicator.getValue(i).quote) {
        lowest = indicator.getValue(i).quote;
      }
    }

    return Tick(epoch: getEpochOfIndex(index), quote: lowest);
  }
}
