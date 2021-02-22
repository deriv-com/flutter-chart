// Aroon Down indicator.
import 'dart:math';

import '../../../../deriv_technical_analysis.dart';

/// Aroon Up Indicator
class AroonUpIndicator<T extends IndicatorResult> extends CachedIndicator<T> {
  /// Initializes a gain indicator from the given [maxValueIndicator].
  ///  @param minValueIndicator the indicator for the min price (default
  ///                       {@link LowValueIndicator})
  AroonUpIndicator.fromIndicator(this.maxValueIndicator, this.barCount)
      :
        // + 1 needed for last possible iteration in loop
        highestValueIndicator =
            HighestValueIndicator<T>(maxValueIndicator, barCount + 1),
        super.fromIndicator(maxValueIndicator);

  /// Indicator to calculate Aroon Down on.
  final Indicator<T> maxValueIndicator;

  /// Indicator to calculate Aroon Down on.
  final Indicator<T> highestValueIndicator;

  /// bar Count
  final int barCount;

  @override
  T calculate(int index) {
    // Getting the number of bars since the highest close price
    final int endIndex = max(0, index - barCount);
    int nbBars = 0;
    for (int i = index; i > endIndex; i--) {
      if (maxValueIndicator.getValue(i).quote ==
          (highestValueIndicator.getValue(index).quote)) {
        break;
      }
      nbBars++;
    }
    return createResult(
        index: index, quote: (barCount - nbBars) / barCount * 100);
  }
}
