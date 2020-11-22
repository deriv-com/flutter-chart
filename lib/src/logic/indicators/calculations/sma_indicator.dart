import 'dart:math';

import '../indicator.dart';
import 'cached_indicator.dart';

class SMAIndicator extends CachedIndicator {
  final Indicator indicator;

  final int barCount;

  SMAIndicator(this.indicator, this.barCount) : super.fromIndicator(indicator);

  @override
  double calculate(int index) {
    double sum = 0.0;
    for (int i = max(0, index - barCount + 1); i <= index; i++) {
      sum += indicator.getValue(i);
    }

    final int realBarCount = min(barCount, index + 1);
    return sum / realBarCount;
  }
}
