import 'package:deriv_chart/src/models/candle.dart';
import 'package:deriv_chart/src/models/tick.dart';

import '../indicator.dart';
import 'cached_indicator.dart';
import 'helper_indicators/high_value_inidicator.dart';
import 'helper_indicators/low_value_indicator.dart';
import 'highest_value_indicator.dart';
import 'lowest_value_indicator.dart';

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
            HighestValueIndicator(HighValueIndicator(candles), barCount),
        _periodLow = LowestValueIndicator(LowValueIndicator(candles), barCount),
        super(candles);

  @override
  Tick calculate(int index) => Tick(
        epoch: candles[index].epoch,
        quote: _periodHigh.getValue(index).quote +
            _periodLow.getValue(index).quote / 2,
      );
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
