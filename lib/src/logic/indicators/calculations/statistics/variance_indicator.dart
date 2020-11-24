import 'dart:math' as math;

import 'package:deriv_chart/src/models/tick.dart';

import '../../indicator.dart';
import '../cached_indicator.dart';
import '../sma_indicator.dart';

/// Variance indicator.
class VarianceIndicator extends CachedIndicator {
  /// [indicator] the indicator
  /// [barCount]  the time frame
  VarianceIndicator(this.indicator, this.barCount)
      : sma = SMAIndicator(indicator, barCount),
        super.fromIndicator(indicator);

  final Indicator indicator;
  final int barCount;
  final SMAIndicator sma;

  @override
  Tick calculate(int index) {
    final int startIndex = math.max(0, index - barCount + 1);
    final int numberOfObservations = index - startIndex + 1;
    double variance = 0;
    double average = sma.getValue(index).quote;
    for (int i = startIndex; i <= index; i++) {
      double pow = math.pow(indicator.getValue(i).quote - average, 2);
      variance = variance + pow;
    }
    variance = variance / numberOfObservations;
    return Tick(epoch: getEpochOfIndex(index), quote: variance);
  }
}
