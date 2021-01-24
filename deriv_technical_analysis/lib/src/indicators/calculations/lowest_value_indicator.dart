import 'dart:math';

import 'package:deriv_technical_analysis/src/models/models.dart';

import '../cached_indicator.dart';
import '../indicator.dart';

/// Lowest value in a range
class LowestValueIndicator<T extends Result> extends CachedIndicator<T> {
  /// Initializes
  LowestValueIndicator(this.indicator, this.period) : super(indicator.input);

  /// Calculating lowest value on the result of this indicator
  final Indicator<T> indicator;

  /// The period
  final int period;

  @override
  T calculate(int index) {
    final int end = max(0, index - period + 1);
    double lowest = indicator.getValue(index).quote;

    for (int i = index - 1; i >= end; i--) {
      if (lowest > indicator.getValue(i).quote) {
        lowest = indicator.getValue(i).quote;
      }
    }

    return createResultOf(epoch: getEpochOfIndex(index), quote: lowest);
  }
}
