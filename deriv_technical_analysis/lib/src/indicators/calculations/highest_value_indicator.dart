import 'dart:math';

import 'package:deriv_technical_analysis/src/models/models.dart';

import '../cached_indicator.dart';
import '../indicator.dart';

/// Highest value in a range
class HighestValueIndicator<T extends IndicatorResult> extends CachedIndicator<T> {
  /// Initializes
  HighestValueIndicator(this.indicator, this.period)
      : super.fromIndicator(indicator);

  /// Calculating highest value on the result of this indicator
  final Indicator<T> indicator;

  /// The period
  final int period;

  @override
  T calculate(int index) {
    final int end = max(0, index - period + 1);
    double highest = indicator.getValue(index).quote;

    for (int i = index - 1; i >= end; i--) {
      if (highest < indicator.getValue(i).quote) {
        highest = indicator.getValue(i).quote;
      }
    }

    return createResult(index: index, quote: highest);
  }
}
