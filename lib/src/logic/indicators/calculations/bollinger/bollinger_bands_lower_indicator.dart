import 'package:deriv_chart/src/models/tick.dart';

import '../../cached_indicator.dart';
import '../../indicator.dart';

/// Bollinger bands lower indicator
class BollingerBandsLowerIndicator extends CachedIndicator<Tick> {
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
  final Indicator<Tick> indicator;

  /// The middle indicator of the BollingerBand
  final Indicator<Tick> bbm;

  /// Default is 2.
  final double k;

  @override
  Tick calculate(int index) => Tick(
        epoch: getEpochOfIndex(index),
        quote:
            bbm.getValue(index).quote - (indicator.getValue(index).quote * k),
      );
}
