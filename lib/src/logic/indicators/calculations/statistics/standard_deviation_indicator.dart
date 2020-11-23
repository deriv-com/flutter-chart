import 'dart:math';

import 'package:deriv_chart/src/models/tick.dart';

import '../../indicator.dart';
import '../cached_indicator.dart';
import 'variance_indicator.dart';

/// Standard deviation indicator.
class StandardDeviationIndicator extends CachedIndicator {
  final VarianceIndicator variance;

  ///
  /// @param indicator the indicator
  /// @param barCount  the time frame
  StandardDeviationIndicator(Indicator indicator, int barCount)
      : variance = new VarianceIndicator(indicator, barCount),
        super.fromIndicator(indicator);

  @override
  Tick calculate(int index) => Tick(
        epoch: getEpochOfIndex(index),
        quote: sqrt(variance.getValue(index).quote),
      );
}
