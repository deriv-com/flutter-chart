import 'dart:math';

import 'package:deriv_chart/src/logic/indicators/calculations/abstract_indicator.dart';
import 'package:deriv_chart/src/models/candle.dart';
import 'package:deriv_chart/src/models/tick.dart';

import 'cached_indicator.dart';

abstract class RecursiveCachedIndicator<T extends Tick>
    extends CachedIndicator<T> {
  /**
   * The recursion threshold for which an iterative calculation is executed. TODO
   * Should be variable (depending on the sub-indicators used in this indicator)
   */
  static final int RECURSION_THRESHOLD = 100;

  /**
   * Constructor.
   *
   * @param series the related bar series
   */
  RecursiveCachedIndicator(List<T> candles) : super(candles);

  /**
   * Constructor.
   *
   * @param indicator a related indicator (with a bar series)
   */
  RecursiveCachedIndicator.fromIndicator(AbstractIndicator indicator)
      : this(indicator.candles);

  @override
  Tick getValue(int index) {
    if (candles != null) {
      final int seriesEndIndex = candles.length - 1;
      if (index <= seriesEndIndex) {
        // We are not after the end of the series
        final int removedBarsCount = 0;
        int startIndex = max(removedBarsCount, highestResultIndex);
        if (index - startIndex > RECURSION_THRESHOLD) {
          // Too many uncalculated values; the risk for a StackOverflowError becomes high.
          // Calculating the previous values iteratively
          for (int prevIdx = startIndex; prevIdx < index; prevIdx++) {
            super.getValue(prevIdx);
          }
        }
      }
    }

    return super.getValue(index);
  }
}
