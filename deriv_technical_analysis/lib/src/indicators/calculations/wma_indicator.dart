import 'package:deriv_technical_analysis/src/models/models.dart';

import '../cached_indicator.dart';
import '../indicator.dart';

/// Weighted Moving Average indicator
class WMAIndicator<T extends Result> extends CachedIndicator<T> {
  /// Initializes
  WMAIndicator(this.indicator, this.period) : super.fromIndicator(indicator);

  /// Bar count
  final int period;

  /// Indicator
  final Indicator<T> indicator;

  @override
  T calculate(int index) {
    if (index == 0) {
      return indicator.getValue(0);
    }
    double value = 0;
    if (index - period < 0) {
      for (int i = index + 1; i > 0; i--) {
        value = value + (i * (indicator.getValue(i - 1).quote));
      }

      return createResult(
        index: index,
        quote: value / (((index + 1) * (index + 2)) / 2),
      );
    }

    int actualIndex = index;

    for (int i = period; i > 0; i--) {
      value = value + (i * (indicator.getValue(actualIndex).quote));
      actualIndex--;
    }

    return createResult(
      index: index,
      quote: value / ((period * (period + 1)) / 2),
    );
  }
}
