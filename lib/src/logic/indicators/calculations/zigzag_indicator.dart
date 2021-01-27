import 'dart:math';

import 'package:deriv_chart/src/models/tick.dart';

import '../cached_indicator.dart';
import '../indicator.dart';

/// The ZigZag Indicator that shows if value changes enough
class ZigZagIndicator extends CachedIndicator {
  /// Initializes
  ZigZagIndicator(this.indicator, this.distance)
      : super.fromIndicator(indicator);

  /// Calculating values that changes enough
  final Indicator indicator;

  /// The minimum distance between two point
  final double distance;

  @override
  Tick calculate(int index) {
    final Tick thisTick = indicator.getValue(index);

    /// the value of zigzag indicator is the same if it's first or last tick
    if (index == 0 || index == indicator.entries.length - 1) {
      return thisTick;
    }

    ///found first not nan value of the indicator before this tick
    for (int i = index - 1; i >= 0; i--) {
      var previousTick = getValue(i);
      if (previousTick.quote.isNaN) {
        continue;
      }

      /// if the last point have enough distance with previous one
      final double distanceInPercent = previousTick.quote * (distance / 100);
      if ((thisTick.quote - previousTick.quote).abs() >= distanceInPercent) {
        return thisTick;
      } else {
        return Tick(epoch: thisTick.epoch, quote: double.nan);
      }
    }
    return Tick(epoch: thisTick.epoch, quote: double.nan);
  }
}
