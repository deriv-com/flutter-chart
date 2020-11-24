import 'dart:math';

import 'package:deriv_chart/src/models/tick.dart';

import '../../indicator.dart';
import '../cached_indicator.dart';
import 'variance_indicator.dart';

/// Standard deviation indicator.
class StandardDeviationIndicator extends CachedIndicator {
  final VarianceIndicator _variance;

  /// [indicator] the indicator
  /// [barCount]  the time frame
  StandardDeviationIndicator(Indicator indicator, int barCount)
      : _variance = VarianceIndicator(indicator, barCount),
        super.fromIndicator(indicator);

  @override
  Tick calculate(int index) => Tick(
        epoch: getEpochOfIndex(index),
        quote: sqrt(_variance.getValue(index).quote),
      );
}
