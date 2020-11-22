import 'dart:math';

import 'abstract_indicator.dart';
import 'cached_indicator.dart';

class LowestValueIndicator extends CachedIndicator {
  final AbstractIndicator indicator;

  final int barCount;

  LowestValueIndicator(this.indicator, this.barCount)
      : super(indicator.candles);

  double calculate(int index) {
    if (indicator.getValue(index).isNaN && barCount != 1) {
      return new LowestValueIndicator(indicator, barCount - 1)
          .getValue(index - 1);
    }
    int end = max(0, index - barCount + 1);
    double lowest = indicator.getValue(index);
    for (int i = index - 1; i >= end; i--) {
      if (lowest > indicator.getValue(i)) {
        lowest = indicator.getValue(i);
      }
    }
    return lowest;
  }
}
