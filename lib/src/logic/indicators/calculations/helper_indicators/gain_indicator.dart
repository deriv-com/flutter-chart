import 'package:deriv_chart/src/logic/indicators/cached_indicator.dart';
import 'package:deriv_chart/src/models/tick.dart';

import '../../indicator.dart';

/// Gain indicator.
class GainIndicator extends CachedIndicator {
  /// Initializes a gain indicator from the given [indicator].
  GainIndicator.fromIndicator(this.indicator) : super.fromIndicator(indicator);

  /// Indicator to calculate Gain on.
  final Indicator indicator;

  @override
  Tick calculate(int index) {
    if (index == 0) {
      return Tick(epoch: getEpochOfIndex(0), quote: 0);
    }
    if (indicator.getValue(index).quote > indicator.getValue(index - 1).quote) {
      return Tick(
          epoch: getEpochOfIndex(index),
          quote: indicator.getValue(index).quote -
              indicator.getValue(index - 1).quote);
    } else {
      return Tick(epoch: getEpochOfIndex(0), quote: 0);
    }
  }
}
