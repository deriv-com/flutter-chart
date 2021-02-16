import 'package:deriv_technical_analysis/src/models/models.dart';

import '../../cached_indicator.dart';
import '../../indicator.dart';

/// Loss indicator.
class LossIndicator<T extends IndicatorResult> extends CachedIndicator<T> {
  /// Initializes a [LossIndicator] from the given [indicator].
  LossIndicator.fromIndicator(this.indicator) : super.fromIndicator(indicator);

  /// Indicator to calculate Loss on.
  final Indicator<T> indicator;

  @override
  T calculate(int index) {
    if (index == 0) {
      return createResult(index: index, quote: 0);
    }
    if (indicator.getValue(index).quote < indicator.getValue(index - 1).quote) {
      return createResult(
          index: index,
          quote: indicator.getValue(index - 1).quote -
              indicator.getValue(index).quote);
    } else {
      return createResult(index: index, quote: 0);
    }
  }
}
