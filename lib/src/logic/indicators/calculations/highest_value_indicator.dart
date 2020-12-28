import 'dart:math';

import 'package:deriv_chart/src/models/tick.dart';

import '../indicator.dart';
import '../cached_indicator.dart';

/// Highest value in a range
class HighestValueIndicator extends CachedIndicator<Tick> {
  /// Initializes
  HighestValueIndicator(this.indicator, this.period)
      : super.fromIndicator(indicator);

  /// Calculating highest value on the result of this indicator
  final Indicator<Tick> indicator;

  /// The period
  final int period;

  @override
  Tick calculate(int index) {
    final int end = max(0, index - period + 1);
    double highest = indicator.getValue(index).quote;

    for (int i = index - 1; i >= end; i--) {
      if (highest < indicator.getValue(i).quote) {
        highest = indicator.getValue(i).quote;
      }
    }

    return Tick(epoch: getEpochOfIndex(index), quote: highest);
  }
}
