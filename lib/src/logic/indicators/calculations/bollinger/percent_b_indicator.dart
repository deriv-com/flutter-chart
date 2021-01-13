import 'package:deriv_chart/src/logic/indicators/calculations/statistics/standard_deviation_indicator.dart';
import 'package:deriv_chart/src/models/tick.dart';

import '../../cached_indicator.dart';
import '../../indicator.dart';
import '../sma_indicator.dart';
import 'bollinger_bands_lower_indicator.dart';
import 'bollinger_bands_upper_indicator.dart';

/// %B Indicator.
class PercentBIndicator extends CachedIndicator {
  /// Initializes
  ///
  /// [indicator] An indicator (usually close price)
  /// [period]  The time frame
  /// [k]         The K multiplier (usually 2.0)
  PercentBIndicator(
    Indicator indicator,
    int period, {
    double k = 2,
  }) : this._(
          indicator,
          StandardDeviationIndicator(indicator, period),
          SMAIndicator(indicator, period),
          k,
        );

  PercentBIndicator._(
    this.indicator,
    StandardDeviationIndicator sd,
    Indicator bbm,
    double k,
  )   : bbu = BollingerBandsUpperIndicator(bbm, sd, k: k),
        bbl = BollingerBandsLowerIndicator(bbm, sd, k: k),
        super.fromIndicator(indicator);

  /// Indicator
  final Indicator indicator;

  /// The upper indicator of the BollingerBand
  final BollingerBandsUpperIndicator bbu;

  /// The lower indicator of the BollingerBand
  final BollingerBandsLowerIndicator bbl;

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
