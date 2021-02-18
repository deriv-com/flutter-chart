import 'package:deriv_technical_analysis/src/indicators/calculations/statistics/standard_deviation_indicator.dart';
import 'package:deriv_technical_analysis/src/models/models.dart';

import '../../cached_indicator.dart';
import '../../indicator.dart';
import '../sma_indicator.dart';
import 'bollinger_bands_lower_indicator.dart';
import 'bollinger_bands_upper_indicator.dart';

/// %B Indicator.
class PercentBIndicator<T extends IndicatorResult> extends CachedIndicator<T> {
  /// Initializes
  ///
  /// [indicator] An indicator (usually close price)
  /// [period]  The time frame
  /// [k]         The K multiplier (usually 2.0)
  PercentBIndicator(
    Indicator<T> indicator,
    int period, {
    double k = 2,
  }) : this._(
          indicator,
          StandardDeviationIndicator<T>(indicator, period),
          SMAIndicator<T>(indicator, period),
          k,
        );

  PercentBIndicator._(
    this.indicator,
    StandardDeviationIndicator<T> sd,
    Indicator<T> bbm,
    double k,
  )   : bbu = BollingerBandsUpperIndicator<T>(bbm, sd, k: k),
        bbl = BollingerBandsLowerIndicator<T>(bbm, sd, k: k),
        super.fromIndicator(indicator);

  /// Indicator
  final Indicator<T> indicator;

  /// The upper indicator of the BollingerBand
  final BollingerBandsUpperIndicator<T> bbu;

  /// The lower indicator of the BollingerBand
  final BollingerBandsLowerIndicator<T> bbl;

  @override
  T calculate(int index) {
    final double value = indicator.getValue(index).quote;
    final double upValue = bbu.getValue(index).quote;
    final double lowValue = bbl.getValue(index).quote;

    return createResult(
      index: index,
      quote: (value - lowValue) / (upValue - lowValue),
    );
  }
}
