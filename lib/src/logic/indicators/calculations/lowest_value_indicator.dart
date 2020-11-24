import 'dart:math';

import 'package:deriv_chart/src/models/tick.dart';

import 'abstract_indicator.dart';
import 'cached_indicator.dart';

/// Lowest price in a range
class LowestValueIndicator extends CachedIndicator {
  /// Initializes
  LowestValueIndicator(this.indicator, this.barCount)
      : super(indicator.entries);

  /// Indicator to calculate Lowest value on
  final AbstractIndicator indicator;

  /// Bar count
  final int barCount;

  @override
  Tick calculate(int index) {
    if (indicator.getValue(index).quote.isNaN && barCount != 1) {
      return new LowestValueIndicator(indicator, barCount - 1)
          .getValue(index - 1);
    }
    int end = max(0, index - barCount + 1);
    double lowest = indicator.getValue(index).quote;
    for (int i = index - 1; i >= end; i--) {
      if (lowest > indicator.getValue(i).quote) {
        lowest = indicator.getValue(i).quote;
      }
    }
    return Tick(epoch: entries[index].epoch, quote: lowest);
  }
}
