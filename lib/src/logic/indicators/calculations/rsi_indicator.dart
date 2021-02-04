import 'package:deriv_chart/src/logic/indicators/cached_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/helper_indicators/gain_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/helper_indicators/loss_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/mma_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/indicator.dart';
import 'package:deriv_chart/src/models/tick.dart';

/// Relative strength index indicator.
class RSIIndicator extends CachedIndicator {
  /// Initializes an [RSIIndicator] from the given [indicator] and [barCount].
  RSIIndicator.fromIndicator(Indicator indicator, int barCount)
      : _averageGainIndicator =
            MMAIndicator(GainIndicator.fromIndicator(indicator), barCount),
        _averageLossIndicator =
            MMAIndicator(LossIndicator.fromIndicator(indicator), barCount),
        super.fromIndicator(indicator);

  final MMAIndicator _averageGainIndicator;
  final MMAIndicator _averageLossIndicator;

  @override
  Tick calculate(int index) {
    final Tick averageGain = _averageGainIndicator.getValue(index);
    final Tick averageLoss = _averageLossIndicator.getValue(index);
    if (averageLoss.quote == 0) {
      if (averageGain.quote == 0) {
        return Tick(epoch: getEpochOfIndex(index), quote: 0);
      } else {
        return Tick(epoch: getEpochOfIndex(index), quote: 100);
      }
    }

    final double relativeStrength = averageGain.quote / averageLoss.quote;

    return Tick(
      epoch: getEpochOfIndex(index),
      quote: 100 - (100 / (1 + relativeStrength)),
    );
  }
}
