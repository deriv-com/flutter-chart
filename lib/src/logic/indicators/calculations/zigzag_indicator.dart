import 'dart:math';

import 'package:deriv_chart/src/models/ohlc.dart';
import 'package:deriv_chart/src/models/tick.dart';

import '../cached_indicator.dart';
import '../indicator.dart';

/// The ZigZag Indicator that shows if value changes enough
class ZigZagIndicator extends CachedIndicator {
  /// Initializes
  ZigZagIndicator(this.indicator, double distance)
      : _distancePercent = distance / 100,
        firstSwingIndex = calculateFirstSwing(indicator),
        super(indicator);

  /// Calculating values that changes enough
  final List<OHLC> indicator;

  /// The minimum distance between two point in %
  final double _distancePercent;

  int firstSwingIndex;

  static int calculateFirstSwing(List<Tick> ticks) {
    int firstIndex = -1;
    if (ticks != null && ticks.isNotEmpty)
      for (int index = 1; index < ticks.length; index++) {
        if ((ticks[index - 1].close > ticks[index].close &&
                ticks[index + 1].close > ticks[index].close) ||
            (ticks[index - 1].close < ticks[index].close &&
                ticks[index + 1].close < ticks[index].close)) {
          firstIndex = index;
          break;
        }
      }
    return firstIndex;
  }

  @override
  Tick calculate(int index) {
    final Tick thisTick = indicator[index];

    /// if index is 0 return nan value
    if (index == 0) {
      return Tick(epoch: thisTick.epoch, quote: double.nan);
    }

    /// if index is last index or first swing, return itself
    if (index == indicator.length - 1 || firstSwingIndex == index) {
      return thisTick;
    }

    /// is the point of given index swing up
    bool isSwingUp(int index) =>
        indicator[index - 1].close < indicator[index].close &&
        indicator[index + 1].close < indicator[index].close;

    /// is the point of given index swing down
    bool isSwingDown(int index) =>
        indicator[index - 1].close > indicator[index].close &&
        indicator[index + 1].close > indicator[index].close;

    /// if thee point is SwingDown or SwingUp
    if (isSwingDown(index) || isSwingUp(index)) {
      /// found first not nan point before this point
      for (int i = index - 1; i > 0; i--) {
        if (getValue(i).quote.isNaN) {
          continue;
        }
        var previousTick = indicator[i];

        ///if this point and last point has different swings
        if ((isSwingUp(index) && isSwingDown(i)) ||
            (isSwingDown(index) && isSwingUp(i))) {
          final double distanceInPercent =
              previousTick.close * _distancePercent;

          if ((previousTick.close - thisTick.close).abs() > distanceInPercent) {
            return isSwingUp(index)
                ? Tick(epoch: thisTick.epoch, quote: thisTick.high)
                : Tick(epoch: thisTick.epoch, quote: thisTick.low);
          } else {
            return Tick(epoch: thisTick.epoch, quote: double.nan);
          }
        }

        ///if this point and last point has similar swings down
        else if (isSwingDown(index) && isSwingDown(i)) {
          if (i != firstSwingIndex && thisTick.close < previousTick.close) {
            results[i] = Tick(epoch: previousTick.epoch, quote: double.nan);
            return Tick(epoch: thisTick.epoch, quote: thisTick.low);
          } else {
            return Tick(epoch: thisTick.epoch, quote: double.nan);
          }
        }

        ///if this point and last point has similar swings up
        else if (isSwingUp(index) && isSwingUp(i)) {
          if (i != firstSwingIndex && thisTick.close > previousTick.close) {
            results[i] = Tick(epoch: previousTick.epoch, quote: double.nan);
            return thisTick;
          } else if (i == firstSwingIndex) {
            final double distanceInPercent =
                previousTick.close * _distancePercent;

            if ((previousTick.close - thisTick.close).abs() >
                distanceInPercent) {
              return Tick(epoch: thisTick.epoch, quote: thisTick.high);
            } else {
              return Tick(epoch: thisTick.epoch, quote: double.nan);
            }
          } else {
            return Tick(epoch: thisTick.epoch, quote: double.nan);
          }
        }

        /// if none of the conditions was true
        else {
          return Tick(epoch: thisTick.epoch, quote: double.nan);
        }
      }
    }
    return Tick(epoch: thisTick.epoch, quote: double.nan);
  }
}
