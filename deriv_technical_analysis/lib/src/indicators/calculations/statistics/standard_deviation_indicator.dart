import 'dart:math';

import 'package:deriv_technical_analysis/src/models/models.dart';

import '../../cached_indicator.dart';
import '../../indicator.dart';
import 'variance_indicator.dart';

/// Standard deviation indicator.
class StandardDeviationIndicator<T extends Result> extends CachedIndicator<T> {
  /// Initializes
  ///
  /// [indicator] the indicator to calculates SD on.
  /// [period]  the time frame
  StandardDeviationIndicator(Indicator<T> indicator, int period)
      : _variance = VarianceIndicator(indicator, period),
        super.fromIndicator(indicator);

  final VarianceIndicator _variance;

  @override
  T calculate(int index) => createResult(
        index: index,
        quote: sqrt(_variance.getValue(index).quote),
      );
}
