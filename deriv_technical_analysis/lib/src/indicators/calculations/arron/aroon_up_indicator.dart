import 'dart:math';

import '../../../../deriv_technical_analysis.dart';

/// Aroon Up Indicator
class AroonUpIndicator<T extends IndicatorResult> extends CachedIndicator<T> {
  /// Initializes a gain indicator from the given [maxValueIndicator].
  /// maxValueIndicator the indicator for the max price
  /// (default is HighValueIndicator)
  AroonUpIndicator.fromIndicator(this.maxValueIndicator, this.period)
      :
        // + 1 needed for last possible iteration in loop
        _highestValueIndicator =
            HighestValueIndicator<T>(maxValueIndicator, period + 1),
        super.fromIndicator(maxValueIndicator);

  /// Indicator to calculate Aroon up on.
  final Indicator<T> maxValueIndicator;

  /// Indicator to calculate highest value.
  final Indicator<T> _highestValueIndicator;

  /// The period
  final int period;

  @override
  T calculate(int index) {
    // Getting the number of bars since the highest close price
    final int endIndex = max(0, index - period);
    int nbBars = 0;
    for (int i = index; i > endIndex; i--) {
      if (maxValueIndicator.getValue(i).quote ==
          (_highestValueIndicator.getValue(index).quote)) {
        break;
      }
      nbBars++;
    }
    return createResult(index: index, quote: (period - nbBars) / period * 100);
  }
}
