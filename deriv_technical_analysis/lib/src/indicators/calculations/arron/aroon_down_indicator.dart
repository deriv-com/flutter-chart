import 'dart:math';

import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';
import 'package:deriv_technical_analysis/src/models/models.dart';

import '../../cached_indicator.dart';
import '../../indicator.dart';

/// Aroon Down indicator.
class AroonDownIndicator<T extends IndicatorResult> extends CachedIndicator<T> {
  /// Initializes a gain indicator from the given [minValueIndicator].
  ///  @param minValueIndicator the indicator for the min price (default
  ///                       {@link LowValueIndicator})
  AroonDownIndicator.fromIndicator(this.minValueIndicator, this.barCount)
      :
        // + 1 needed for last possible iteration in loop
        lowestValueIndicator =
            LowestValueIndicator<T>(minValueIndicator, barCount + 1),
        super.fromIndicator(minValueIndicator);

  /// Indicator to calculate Aroon Down on.
  final Indicator<T> minValueIndicator;

  /// Indicator to calculate Aroon Down on.
  final Indicator<T> lowestValueIndicator;

  /// bar Count
  final int barCount;

  @override
  T calculate(int index) {
    // Getting the number of bars since the lowest close price
    final int endIndex = max(0, index - barCount);
    int nbBars = 0;
    for (int i = index; i > endIndex; i--) {
      if (minValueIndicator.getValue(i).quote ==
          (lowestValueIndicator.getValue(index).quote)) {
        break;
      }
      nbBars++;
    }
    return createResult(
        index: index, quote: ((barCount - nbBars) / barCount) * 100);
  }
}
