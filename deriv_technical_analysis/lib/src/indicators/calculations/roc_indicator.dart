import 'dart:math';

import 'package:deriv_technical_analysis/src/models/models.dart';

import '../cached_indicator.dart';
import '../indicator.dart';

///  Price Rate Of Change Indicator indicator.
class ROCIndicator<T extends IndicatorResult> extends CachedIndicator<T> {
  /// Initializes an [ROCIndicator] from the given [indicator] and [period].
  ROCIndicator.fromIndicator(this.indicator, this.period)
      : super.fromIndicator(indicator);

  /// Calculating lowest value on the result of this indicator
  final Indicator<T> indicator;

  /// period of Roc
  final int period;

  @override
  T calculate(int index) {
    final int nIndex = max(index - period, 0);
    final double nPeriodsAgoValue = indicator.getValue(nIndex).quote;
    final double currentValue = indicator.getValue(index).quote;

    return createResult(
      index: index,
      quote: (currentValue - nPeriodsAgoValue) / nPeriodsAgoValue * 100,
    );
  }
}
