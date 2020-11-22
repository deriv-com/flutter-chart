import 'dart:math';

import 'package:deriv_chart/deriv_chart.dart';

/// An indicator
abstract class Indicator {
  /// Value of the indicator for the given [index].
  double getValue(int index);
}

/// Bass class of all indicators.
abstract class AbstractIndicator implements Indicator {
  final List<Candle> candles;

  AbstractIndicator(this.candles);
}

/// Handling a level of caching
abstract class CachedIndicator extends AbstractIndicator {
  CachedIndicator(List<Candle> candles) : super(candles) {
    for (int i = 0; i < candles.length; i++) {
      results.add(getValue(i));
    }
  }

  CachedIndicator.fromIndicator(AbstractIndicator indicator)
      : this(indicator.candles);

  /// List of cached result.
  final List<double> results = <double>[];

  @override
  // TODO(Ramin): Add caching logic if we it someday.
  double getValue(int index) => calculate(index);

  /// Calculates the value of this indicator for the give [index]
  double calculate(int index);
}

class HighValueIndicator extends CachedIndicator {
  HighValueIndicator(List<Candle> candles) : super(candles);

  @override
  double calculate(int index) => candles[index].high;
}

class LowValueIndicator extends CachedIndicator {
  LowValueIndicator(List<Candle> candles) : super(candles);

  @override
  double calculate(int index) => candles[index].low;
}

class HighestValueIndicator extends CachedIndicator {
  final AbstractIndicator indicator;

  final int barCount;

  HighestValueIndicator(this.indicator, this.barCount)
      : super(indicator.candles);

  double calculate(int index) {
    if (indicator.getValue(index).isNaN && barCount != 1) {
      return HighestValueIndicator(indicator, barCount - 1).getValue(index - 1);
    }
    int end = max(0, index - barCount + 1);
    double highest = indicator.getValue(index);
    for (int i = index - 1; i >= end; i--) {
      if (highest < getValue(i)) {
        highest = indicator.getValue(i);
      }
    }
    return highest;
  }
}

class LowestValueIndicator extends CachedIndicator {
  final AbstractIndicator indicator;

  final int barCount;

  LowestValueIndicator(this.indicator, this.barCount)
      : super(indicator.candles);

  double calculate(int index) {
    if (indicator.getValue(index).isNaN && barCount != 1) {
      return new LowestValueIndicator(indicator, barCount - 1)
          .getValue(index - 1);
    }
    int end = max(0, index - barCount + 1);
    double lowest = indicator.getValue(index);
    for (int i = index - 1; i >= end; i--) {
      if (lowest > indicator.getValue(i)) {
        lowest = indicator.getValue(i);
      }
    }
    return lowest;
  }
}

class AbstractIchimokuLineIndicator extends CachedIndicator {
  /** The period high */
  final Indicator _periodHigh;

  /** The period low */
  final Indicator _periodLow;

  /**
   * Contructor.
   *
   * @param series   the series
   * @param barCount the time frame
   */
  AbstractIchimokuLineIndicator(List<Candle> candles, int barCount)
      : _periodHigh =
            new HighestValueIndicator(HighValueIndicator(candles), barCount),
        _periodLow =
            new LowestValueIndicator(LowValueIndicator(candles), barCount),
        super(candles);

  @override
  double calculate(int index) {
    return _periodHigh.getValue(index) + (_periodLow.getValue(index)) / 2;
  }
}

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

//
// abstracttract class RecursiveCachedIndicator extends AbstractIndicator {
//
//   /**
//    * The recursion threshold for which an iterative calculation is executed. TODO
//    * Should be variable (depending on the sub-indicators used in this indicator)
//    */
//   final int RECURSION_THRESHOLD = 100;
//
//   /**
//    * Constructor.
//    *
//    * @param series the related bar series
//    */
//   public RecursiveCachedIndicator(BarSeries series) {
//     super(series);
//   }
//
//   /**
//    * Constructor.
//    *
//    * @param indicator a related indicator (with a bar series)
//    */
//   public RecursiveCachedIndicator
//
//   (
//
//   Indicator
//
//   <
//
//   ?
//
//   >
//
//   indicator
//
//   ) {
//   this(indicator.getBarSeries());
//   }
//
//   @override
//   double getValue(int index) {
//     BarSeries series = getBarSeries();
//     if (series != null) {
//       final int seriesEndIndex = series.getEndIndex();
//       if (index <= seriesEndIndex) {
//         // We are not after the end of the series
//         final int removedBarsCount = series.getRemovedBarsCount();
//         int startIndex = max(removedBarsCount, highestResultIndex);
//         if (index - startIndex > RECURSION_THRESHOLD) {
//           // Too many uncalculated values; the risk for a StackOverflowError becomes high.
//           // Calculating the previous values iteratively
//           for (int prevIdx = startIndex; prevIdx < index; prevIdx++) {
//             super.getValue(prevIdx);
//           }
//         }
//       }
//     }
//
//     return super.getValue(index);
//   }
// }
//
// abstract class AbstractEMAIndicator extends RecursiveCachedIndicator<Num> {
//
//   private static
//
//   final long serialVersionUID = -7312565662007443461
//
//   L
//
//   ;
//
//   private
//
//   final Indicator<Num> indicator;
//
//   private
//
//   final int barCount;
//
//   private
//
//   final Num multiplier;
//
//   public AbstractEMAIndicator(Indicator<Num> indicator, int barCount,
//       double multiplier) {
//     super(indicator);
//     this.indicator = indicator;
//     this.barCount = barCount;
//     this.multiplier = numOf(multiplier);
//   }
//
//   @Override
//   protected Num
//
//   calculate(int index) {
//     if (index == 0) {
//       return indicator.getValue(0);
//     }
//     Num prevValue = getValue(index - 1);
//     return indicator.getValue(index).minus(prevValue)
//         .multipliedBy(multiplier)
//         .plus(prevValue);
//   }
//
//   @Override
//   public String
//
//   toString() {
//     return getClass().getSimpleName() + " barCount: " + barCount;
//   }
// }
