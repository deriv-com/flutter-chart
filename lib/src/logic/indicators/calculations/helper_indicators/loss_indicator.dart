import 'package:deriv_chart/src/logic/indicators/cached_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/indicator.dart';
import 'package:deriv_chart/src/models/tick.dart';

/// Loss indicator.
class LossIndicator extends CachedIndicator {
  /// Initializes a [LossIndicator] from the given [indicator].
  LossIndicator.fromIndicator(this.indicator) : super.fromIndicator(indicator);

  /// Indicator to calculate Loss on.
  final Indicator indicator;

  @override
  Tick calculate(int index) {
    if (index == 0) {
      return Tick(epoch: getEpochOfIndex(index), quote: 0);
    }
    if (indicator.getValue(index).quote < indicator.getValue(index - 1).quote) {
      return Tick(
          epoch: getEpochOfIndex(index),
          quote: indicator.getValue(index - 1).quote -
              indicator.getValue(index).quote);
    } else {
      return Tick(epoch: getEpochOfIndex(index), quote: 0);
    }
  }
}
