import 'dart:math';

import 'package:deriv_chart/src/models/tick.dart';

import '../cached_indicator.dart';
import '../indicator.dart';

/// Simple Moving Average Indicator
class SMAIndicator extends CachedIndicator {
  /// Initializes
  SMAIndicator(this.indicator, this.barCount) : super.fromIndicator(indicator);

  /// Indicator to calculate SMA on
  final Indicator indicator;

  /// Bar count
  final int barCount;

  @override
  Tick calculate(int index) {
    double sum = 0.0;
    for (int i = max(0, index - barCount + 1); i <= index; i++) {
      sum += indicator.getValue(i).quote;
    }

    final int realBarCount = min(barCount, index + 1);
    return Tick(epoch: entries[index].epoch, quote: sum / realBarCount);
  }
}
