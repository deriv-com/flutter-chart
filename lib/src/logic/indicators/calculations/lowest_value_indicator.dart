import 'dart:math';

import 'package:deriv_chart/src/models/tick.dart';

import '../cached_indicator.dart';
import '../indicator.dart';

/// Lowest value in a range
class LowestValueIndicator extends CachedIndicator {
  /// Initializes
  LowestValueIndicator(this.indicator, this.period)
      : super(indicator.entries);

  /// Calculating lowest value on the result of this indicator
  final Indicator indicator;

  /// The period
  final int period;

  @override
  Tick calculate(int index) {
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
