import 'dart:math';

import 'package:deriv_chart/src/models/ohlc.dart';
import 'package:deriv_chart/src/models/tick.dart';

import '../cached_indicator.dart';
import '../indicator.dart';

/// The ZigZag Indicator that shows if value changes enough
class ZigZagIndicator extends CachedIndicator {
  /// Initializes
  ZigZagIndicator(this.ticks, double distance)
      : _distancePercent = distance / 100,
        super(ticks);

  /// Calculating values that changes enough
  final List<OHLC> ticks;

  /// The minimum distance between two point in %
  final double _distancePercent;

  @override
  Tick calculate(int index) {
    final Tick thisTick = ticks[index];

    /// the value of zigzag indicator is the same if it's first or last tick
    if (index == 0 || index == ticks.length - 1) {
      return thisTick;
    }

    //found first not nan value of the indicator before this tick
    for (int i = index - 1; i >= 0; i--) {
      Tick previousTick = getValue(i);
      if (previousTick.quote.isNaN) {
        continue;
      }

      bool trendUp;

      final double changeUp =
          (thisTick.high - previousTick.low) / previousTick.low;
      final double changeDown =
          (previousTick.high - thisTick.low) / previousTick.high;

      if (changeUp > changeDown) {
        trendUp = true;
      }

      if (changeDown > changeUp) {
        trendUp = false;
      }

      if (trendUp) {
        final double change = _distancePercent * previousTick.low;
        // if ((thisTick.high - previousTick.low).abs() >= change) {
        //   return thisTick;
        // }
        if (thisTick.high < previousTick.low && ((thisTick.high-previousTick.low) / previousTick.low)>=_distancePercent) {
          return Tick(epoch: thisTick.epoch, quote: thisTick.high);
        }
        else {
          return Tick(epoch: thisTick.epoch, quote: double.nan);
        }
      } else {
        final double change = _distancePercent * previousTick.high;
    if (thisTick.low > previousTick.high &&((thisTick.low - previousTick.high) / previousTick.high)>=_distancePercent ) {
      return thisTick;
    }
        else {
          return Tick(epoch: thisTick.epoch, quote: double.nan);
        }

      }
    }

    // ///found first not nan value of the indicator before this tick
    // for (int i = index - 1; i >= 0; i--) {
    //   var previousTick = getValue(i);
    //   if (previousTick.quote.isNaN) {
    //     continue;
    //   }
    //
    //   /// if the last point have enough distance with previous one
    //   final double distanceInPercent = previousTick.quote * _distancePercent;
    //   if ((thisTick.quote - previousTick.quote).abs() >= distanceInPercent) {
    //     return thisTick;
    //   } else {
    //     return Tick(epoch: thisTick.epoch, quote: double.nan);
    //   }
    // }
    // return Tick(epoch: thisTick.epoch, quote: double.nan);
  }
}
