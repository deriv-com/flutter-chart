import 'dart:math';

import 'package:deriv_chart/src/models/tick.dart';

import 'abstract_indicator.dart';
import 'cached_indicator.dart';

class LowestValueIndicator extends CachedIndicator {
  final AbstractIndicator indicator;

  final int barCount;

  LowestValueIndicator(this.indicator, this.barCount)
      : super(indicator.candles);

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
    return Tick(epoch: candles[index].epoch, quote: lowest);
  }
}
