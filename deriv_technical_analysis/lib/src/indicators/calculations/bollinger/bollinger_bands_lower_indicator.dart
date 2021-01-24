import 'package:deriv_technical_analysis/src/models/models.dart';

import '../../cached_indicator.dart';
import '../../indicator.dart';

/// Bollinger bands lower indicator
class BollingerBandsLowerIndicator<T extends Result>
    extends CachedIndicator<T> {
  /// Initializes.
  ///
  /// [k]         Defaults value to 2.
  ///
  /// [bbm]       the middle band Indicator. Typically an SMAIndicator is used.
  ///
  /// [indicator] the deviation above and below the middle, factored by k.
  ///             Typically a StandardDeviationIndicator is used.
  BollingerBandsLowerIndicator(this.bbm, this.indicator, {this.k = 2})
      : super.fromIndicator(bbm);

  /// Indicator
  final Indicator indicator;

  /// The middle indicator of the BollingerBand
  final Indicator bbm;

  /// Default is 2.
  final double k;

  @override
  T calculate(int index) => createResultOf(
        epoch: getEpochOfIndex(index),
        quote:
            bbm.getValue(index).quote - (indicator.getValue(index).quote * k),
      );
}
