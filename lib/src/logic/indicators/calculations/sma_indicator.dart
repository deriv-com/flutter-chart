import 'dart:math';

import 'package:deriv_chart/src/models/tick.dart';

import '../abstract_indicator.dart';
import '../cached_indicator.dart';

/// Simple Moving Average Indicator
class SMAIndicator extends CachedIndicator<Tick> {
  /// Initializes
  SMAIndicator(this.indicator, this.period) : super.fromIndicator(indicator);

  /// Indicator to calculate SMA on
  final AbstractIndicator<Tick> indicator;

  /// Bar count
  final int period;

  @override
  Tick calculate(int index) {
    double sum = 0;
    for (int i = max(0, index - period + 1); i <= index; i++) {
      sum += indicator.getValue(i).quote;
    }

    final int realBarCount = min(period, index + 1);

    return Tick(epoch: getEpochOfIndex(index), quote: sum / realBarCount);
  }
}
