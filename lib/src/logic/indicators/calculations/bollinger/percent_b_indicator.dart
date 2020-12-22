import 'package:deriv_chart/src/logic/indicators/calculations/statistics/standard_deviation_indicator.dart';
import 'package:deriv_chart/src/models/tick.dart';

import '../../abstract_indicator.dart';
import '../../cached_indicator.dart';
import '../sma_indicator.dart';
import 'bollinger_bands_lower_indicator.dart';
import 'bollinger_bands_middle_indicator.dart';
import 'bollinger_bands_upper_indicator.dart';

/// %B Indicator.
class PercentBIndicator extends CachedIndicator<Tick> {
  /// Initializes
  ///
  /// [indicator] An indicator (usually close price)
  /// [period]  The time frame
  /// [k]         The K multiplier (usually 2.0)
  PercentBIndicator(AbstractIndicator<Tick> indicator, int period,
      {double k = 2})
      : this._(
          indicator,
          StandardDeviationIndicator(indicator, period),
          BollingerBandsMiddleIndicator(SMAIndicator(indicator, period)),
          period,
          k,
        );

  PercentBIndicator._(
    this.indicator,
    StandardDeviationIndicator sd,
    BollingerBandsMiddleIndicator bbm,
    int period,
    double k,
  )   : bbu = BollingerBandsUpperIndicator(bbm, sd, k: k),
        bbl = BollingerBandsLowerIndicator(bbm, sd, k: k),
        super.fromIndicator(indicator);

  /// Indicator
  final AbstractIndicator<Tick> indicator;

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
