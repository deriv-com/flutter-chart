import 'dart:math';

import 'package:deriv_chart/src/models/tick.dart';

import 'abstract_indicator.dart';
import 'cached_indicator.dart';

class HighestValueIndicator extends CachedIndicator {
  final AbstractIndicator indicator;

  final int barCount;

  HighestValueIndicator(this.indicator, this.barCount)
      : super.fromIndicator(indicator);

  @override
  Tick calculate(int index) {
    if (indicator.getValue(index).quote.isNaN && barCount != 1) {
      return HighestValueIndicator(indicator, barCount - 1).getValue(index - 1);
    }
    int end = max(0, index - barCount + 1);
    double highest = indicator.getValue(index).quote;
    for (int i = index - 1; i >= end; i--) {
      if (highest < getValue(i).quote) {
        highest = indicator.getValue(i).quote;
      }
    }
    return Tick(epoch: candles[index].epoch, quote: highest);
  }
}
