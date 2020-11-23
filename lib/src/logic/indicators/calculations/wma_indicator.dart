import 'package:deriv_chart/src/models/tick.dart';

import '../indicator.dart';
import 'cached_indicator.dart';

/// WMA indicator
class WMAIndicator extends CachedIndicator {
  WMAIndicator(this.indicator, this.barCount) : super.fromIndicator(indicator);

  final int barCount;
  final Indicator indicator;

  @override
  Tick calculate(int index) {
    if (index == 0) {
      return indicator.getValue(0);
    }
    double value = 0;
    if (index - barCount < 0) {
      for (int i = index + 1; i > 0; i--) {
        value = value + (i * (indicator.getValue(i - 1).quote));
      }
      return Tick(
        epoch: getEpochOfIndex(index),
        quote: value / (((index + 1) * (index + 2)) / 2),
      );
    }

    int actualIndex = index;
    for (int i = barCount; i > 0; i--) {
      value = value + (i * (indicator.getValue(actualIndex).quote));
      actualIndex--;
    }
    return Tick(
      epoch: getEpochOfIndex(index),
      quote: value / ((barCount * (barCount + 1)) / 2),
    );
  }
}
