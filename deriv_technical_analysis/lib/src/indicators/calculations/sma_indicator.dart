import 'dart:math';

import 'package:deriv_technical_analysis/src/models/models.dart';

import '../cached_indicator.dart';
import '../indicator.dart';

/// Simple Moving Average Indicator
class SMAIndicator<T extends IndicatorResult> extends CachedIndicator<T> {
  /// Initializes
  SMAIndicator(this.indicator, this.period) : super.fromIndicator(indicator);

  /// Indicator to calculate SMA on
  final Indicator<T> indicator;

  /// Bar count
  final int period;

  @override
  T calculate(int index) {
    double sum = 0;
    for (int i = max(0, index - period + 1); i <= index; i++) {
      sum += indicator.getValue(i).quote;
    }

    final int realBarCount = min(period, index + 1);

    return createResult(index: index, quote: sum / realBarCount);
  }
}
