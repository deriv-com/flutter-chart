import 'dart:math' as math;

import 'package:deriv_technical_analysis/src/models/models.dart';

import '../../cached_indicator.dart';
import '../../indicator.dart';
import '../sma_indicator.dart';

/// Variance indicator.
class VarianceIndicator<T extends Result> extends CachedIndicator<T> {
  /// Initializes
  ///
  /// [indicator] the indicator
  /// [period]  the time frame
  VarianceIndicator(this.indicator, this.period)
      : _sma = SMAIndicator(indicator, period),
        super.fromIndicator(indicator);

  /// Indicator
  final Indicator<T> indicator;

  /// Bar count
  final int period;

  final SMAIndicator _sma;

  @override
  T calculate(int index) {
    final int startIndex = math.max(0, index - period + 1);
    final int numberOfObservations = index - startIndex + 1;
    double variance = 0;
    final double average = _sma.getValue(index).quote;

    for (int i = startIndex; i <= index; i++) {
      final double pow = math.pow(indicator.getValue(i).quote - average, 2);
      variance = variance + pow;
    }

    variance = variance / numberOfObservations;

    return createResult(index: index, quote: variance);
  }
}
