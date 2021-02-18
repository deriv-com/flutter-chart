import 'package:deriv_technical_analysis/src/models/models.dart';

import '../../cached_indicator.dart';
import '../../indicator.dart';

/// Gain indicator.
class GainIndicator<T extends IndicatorResult> extends CachedIndicator<T> {
  /// Initializes a gain indicator from the given [indicator].
  GainIndicator.fromIndicator(this.indicator) : super.fromIndicator(indicator);

  /// Indicator to calculate Gain on.
  final Indicator<T> indicator;

  @override
  T calculate(int index) {
    if (index == 0) {
      return createResult(index: 0, quote: 0);
    }
    if (indicator.getValue(index).quote > indicator.getValue(index - 1).quote) {
      return createResult(
          index: index,
          quote: indicator.getValue(index).quote -
              indicator.getValue(index - 1).quote);
    } else {
      return createResult(index: 0, quote: 0);
    }
  }
}
