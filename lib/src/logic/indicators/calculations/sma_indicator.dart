import 'dart:math';

import 'package:deriv_chart/src/models/tick.dart';

import '../indicator.dart';
import 'cached_indicator.dart';

class SMAIndicator extends CachedIndicator {
  final Indicator indicator;

  final int barCount;

  SMAIndicator(this.indicator, this.barCount) : super.fromIndicator(indicator);

  @override
  Tick calculate(int index) {
    double sum = 0.0;
    for (int i = max(0, index - barCount + 1); i <= index; i++) {
      sum += indicator.getValue(i).quote;
    }

    final int realBarCount = min(barCount, index + 1);
    return Tick(epoch: candles[index].epoch, quote: sum / realBarCount);
  }
}
