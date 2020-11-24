import 'package:deriv_chart/src/logic/indicators/calculations/statistics/standard_deviation_indicator.dart';
import 'package:deriv_chart/src/models/tick.dart';

import '../../indicator.dart';
import '../cached_indicator.dart';
import '../sma_indicator.dart';
import 'bollinger_bands_lower_indicator.dart';
import 'bollinger_bands_middle_indicator.dart';
import 'bollinger_bands_upper_indicator.dart';

/// %B indicator.
class PercentBIndicator extends CachedIndicator {
  final Indicator indicator;

  final BollingerBandsUpperIndicator bbu;

  final BollingerBandsLowerIndicator bbl;

  PercentBIndicator._(
    this.indicator,
    StandardDeviationIndicator sd,
    BollingerBandsMiddleIndicator bbm,
    int barCount,
    double k,
  )   : bbu = BollingerBandsUpperIndicator(bbm, sd, k: k),
        bbl = BollingerBandsLowerIndicator(bbm, sd, k: k),
        super.fromIndicator(indicator);

  ///
  /// Initializes
  ///
  /// [indicator] an indicator (usually close price)
  /// [barCount]  the time frame
  /// [k]         the K multiplier (usually 2.0)
  PercentBIndicator(Indicator indicator, int barCount, double k)
      : this._(
          indicator,
          StandardDeviationIndicator(indicator, barCount),
          BollingerBandsMiddleIndicator(SMAIndicator(indicator, barCount)),
          barCount,
          k,
        );

  @override
  Tick calculate(int index) {
    final double value = indicator.getValue(index).quote;
    final double upValue = bbu.getValue(index).quote;
    final double lowValue = bbl.getValue(index).quote;
    return Tick(
      epoch: getEpochOfIndex(index),
      quote: (value - lowValue) / (upValue - lowValue),
    );
  }
}
