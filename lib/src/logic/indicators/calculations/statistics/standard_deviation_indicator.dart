import 'dart:math';

import 'package:deriv_chart/src/models/tick.dart';

import '../../cached_indicator.dart';
import '../../indicator.dart';
import 'variance_indicator.dart';

/// Standard deviation indicator.
class StandardDeviationIndicator extends CachedIndicator {
  /// Initializes
  ///
  /// [indicator] the indicator to calculates SD on.
  /// [period]  the time frame
  StandardDeviationIndicator(Indicator indicator, int period)
      : _variance = VarianceIndicator(indicator, period),
        super.fromIndicator(indicator);

  final VarianceIndicator _variance;

  @override
  Tick calculate(int index) => Tick(
        epoch: getEpochOfIndex(index),
        quote: sqrt(_variance.getValue(index).quote),
      );
}
