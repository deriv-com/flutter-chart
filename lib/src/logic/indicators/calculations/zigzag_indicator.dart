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
        upSwingTicks = calculateSwingUpPoints(ticks),
        downSwingTicks = calculateSwingDownPoints(ticks),
        super(ticks);

  /// Calculating values that changes enough
  final List<OHLC> ticks;
  List<OHLC> upSwingTicks;
  List<OHLC> downSwingTicks;

  /// The minimum distance between two point in %
  final double _distancePercent;

  static List<OHLC> calculateSwingUpPoints(List<OHLC> ticks) {
    List<OHLC> swingups=[];
    for (int index = 1; index < ticks.length-1; index++) {
      if (ticks[index - 1].close < ticks[index].close &&
          ticks[index + 1].close < ticks[index].close) {
        swingups.add(ticks[index]);
      }
    }
    return swingups;
  }

  static List<OHLC> calculateSwingDownPoints(List<OHLC> ticks) {
    List<OHLC> swingDowns=[];
    for (int index = 1; index < ticks.length-1; index++) {
      if (ticks[index - 1].close > ticks[index].close &&
          ticks[index + 1].close > ticks[index].close) {
        swingDowns.add(ticks[index]);
      }
    }
    return swingDowns;
  }

  bool isFirstSwing(int index) {
    int fisrtIndex = -1;
    for (int index = 1; index < ticks.length; index++) {
      if ((ticks[index - 1].close > ticks[index].close &&
          ticks[index + 1].close > ticks[index].close) ||
          (ticks[index - 1].close < ticks[index].close &&
              ticks[index + 1].close < ticks[index].close)) {
        fisrtIndex = index;
        break;
      }
    }
    return fisrtIndex==index? true: false;
  }
  @override
  Tick calculate(int index) {
    final Tick thisTick = ticks[index];
    if(index==0){
      return Tick(epoch: thisTick.epoch, quote: double.nan);
    }
    if (index == ticks.length - 1 || isFirstSwing(index)) {
      return thisTick;
    }

    if (upSwingTicks.contains(thisTick)) {
      for (int i = index - 1; i > 0; i--) {
        var previousTick = ticks[i];
        if ( getValue(i).quote.isNaN) {
          continue;
        }
        if (downSwingTicks.contains(previousTick)) {
          final double distanceInPercent = previousTick.high * _distancePercent;
          if ((previousTick.high - thisTick.low).abs() > distanceInPercent)
            return thisTick;
          else {
            return Tick(epoch: thisTick.epoch, quote: double.nan);
          }
        }
      }
    }

    if (downSwingTicks.contains(thisTick)) {
      for (int i = index - 1; i > 0; i--) {
        var previousTick = ticks[i];
        if (getValue(i).quote.isNaN) {
          continue;
        }
        if (upSwingTicks.contains(previousTick)) {
          final double distanceInPercent = previousTick.low *
              _distancePercent;
          if ((previousTick.low - thisTick.high).abs() > distanceInPercent)
            return thisTick;
          else {
            return Tick(epoch: thisTick.epoch, quote: double.nan);
          }
        }
      }
    }
    return Tick(epoch: thisTick.epoch, quote: double.nan);

    // bool isSwingUp(int index) =>
    //     ticks[index - 1].close < ticks[index].close &&
    //         ticks[index + 1].close < ticks[index].close;
    //
    // bool isSwingDown(int index) =>
    //     ticks[index - 1].close > ticks[index].close &&
    //         ticks[index + 1].close > ticks[index].close;
    //
    // if (index == ticks.length - 2) {
    //   print("Aaaaa");
    // }
    //
    // /// the value of zigzag indicator is the same if it's first or last tick
    // if (index == ticks.length - 1) {
    //   return thisTick;
    // }
    // if (index == 0) {
    //   return Tick(epoch: thisTick.epoch, quote: double.nan);
    // }
    //
    // bool isThisTickSwingDown = isSwingDown(index);
    // bool isThisTickSwingUp = isSwingUp(index);
    //
    // if (isThisTickSwingDown || isThisTickSwingUp) {
    //   ///found first not nan value of the indicator before this tick
    //   for (int i = index - 1; i >= 0; i--) {
    //     var previousTick = getValue(i);
    //     if (previousTick.quote.isNaN) {
    //       continue;
    //     }
    //
    //     if (i == 0) {
    //       if (isThisTickSwingUp) {
    //         final double distanceInPercent = previousTick.high *
    //             _distancePercent;
    //         if ((previousTick.high - thisTick.low).abs() > distanceInPercent)
    //           return thisTick;
    //         else {
    //           return Tick(epoch: thisTick.epoch, quote: double.nan);
    //         }
    //       }
    //       else if (isThisTickSwingDown) {
    //         final double distanceInPercent = previousTick.low *
    //             _distancePercent;
    //         if ((previousTick.low - thisTick.high).abs() > distanceInPercent)
    //           return thisTick;
    //         else {
    //           return Tick(epoch: thisTick.epoch, quote: double.nan);
    //         }
    //       }
    //     }
    //     else if (i != 0) {
    //       if (isThisTickSwingUp && isSwingDown(i)) {
    //         final double distanceInPercent = previousTick.high *
    //             _distancePercent;
    //         if ((previousTick.high - thisTick.low).abs() > distanceInPercent)
    //           return thisTick;
    //         else {
    //           return Tick(epoch: thisTick.epoch, quote: double.nan);
    //         }
    //       }
    //       else if (isThisTickSwingDown && isSwingUp(i)) {
    //         final double distanceInPercent = previousTick.low *
    //             _distancePercent;
    //         if ((previousTick.low - thisTick.high).abs() > distanceInPercent)
    //           return thisTick;
    //         else {
    //           return Tick(epoch: thisTick.epoch, quote: double.nan);
    //         }
    //       }
    //     }
    //     else {
    //       continue;
    //     }
    //   }
    //   if (isThisTickSwingUp || isThisTickSwingDown) {
    //     return thisTick;
    //   }
    // }
    // return Tick(epoch: thisTick.epoch, quote: double.nan);
  }

//   /// the value of zigzag indicator is the same if it's first or last tick
//   if (index == 0 || index == ticks.length - 1) {
//     return thisTick;
//   }
//
//   if (isSwingUp(index) || isSwingDown(index)) {
//     ///found first not nan value of the indicator before this tick
//     for (int i = index - 1; i >= 0; i--) {
//       var previousTick = getValue(i);
//       if (previousTick.quote.isNaN) {
//         continue;
//       }
//
//       /// if the last point have enough distance with previous one
//       final double distanceInPercent = previousTick.close * _distancePercent;
//       if (i == 0) {
//         if ((thisTick.close - previousTick.close).abs() >=
//             distanceInPercent) {
//           return thisTick;
//         } else {
//           return Tick(epoch: thisTick.epoch, quote: double.nan);
//         }
//       } else {
//
//         if(isThisTickSwingDown && isSwingUp(i)){
//
//         }
//
//
//
//         if ((isSwingUp(i) || isSwingDown(i)) &&
//             (thisTick.close - previousTick.close).abs() >=
//                 distanceInPercent) {
//           return thisTick;
//         } else {
//           return Tick(epoch: thisTick.epoch, quote: double.nan);
//         }
//       }
//     }
//   }
//
//   return Tick(epoch: thisTick.epoch, quote: double.nan);
// }

}
