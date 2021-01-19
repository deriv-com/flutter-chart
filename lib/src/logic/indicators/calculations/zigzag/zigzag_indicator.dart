import 'dart:math';

import 'package:deriv_chart/src/models/tick.dart';

import '../../cached_indicator.dart';
import '../../indicator.dart';



/// Highest value in a range
class ZigZagIndicator extends CachedIndicator {
  /// Initializes
  ZigZagIndicator(this.indicator, this.distance)
      : super.fromIndicator(indicator);

  /// Calculating highest value on the result of this indicator
  final Indicator indicator;

  /// The period
  final int distance;

  @override
  Tick calculate(int index) {
    final int end = max(0, index - distance + 1);
    double highest = indicator.getValue(index).quote;

    for (int i = index - 1; i >= end; i--) {
      if (highest < indicator.getValue(i).quote) {
        highest = indicator.getValue(i).quote;
      }
    }

    return Tick(epoch: getEpochOfIndex(index), quote: highest);
  }
}
