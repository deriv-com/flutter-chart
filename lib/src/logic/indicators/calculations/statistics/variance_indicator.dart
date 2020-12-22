import 'dart:math' as math;

import 'package:deriv_chart/src/models/tick.dart';

import '../../abstract_indicator.dart';
import '../../cached_indicator.dart';
import '../sma_indicator.dart';

/// Variance indicator.
class VarianceIndicator extends CachedIndicator<Tick> {
  /// Initializes
  ///
  /// [indicator] the indicator
  /// [period]  the time frame
  VarianceIndicator(this.indicator, this.period)
      : _sma = SMAIndicator(indicator, period),
        super.fromIndicator(indicator);

  /// Indicator
  final AbstractIndicator<Tick> indicator;

  /// Bar count
  final int period;

  final SMAIndicator _sma;

  @override
  Tick calculate(int index) {
    final int startIndex = math.max(0, index - period + 1);
    final int numberOfObservations = index - startIndex + 1;
    double variance = 0;
    final double average = _sma.getValue(index).quote;

    for (int i = startIndex; i <= index; i++) {
      final double pow = math.pow(indicator.getValue(i).quote - average, 2);
      variance = variance + pow;
    }

    variance = variance / numberOfObservations;

    return Tick(epoch: getEpochOfIndex(index), quote: variance);
  }
}
