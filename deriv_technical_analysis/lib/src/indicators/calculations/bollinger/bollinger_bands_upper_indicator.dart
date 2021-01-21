import 'package:deriv_technical_analysis/src/models/tick.dart';

import '../../cached_indicator.dart';
import '../../indicator.dart';

/// Bollinger bands upper indicator
class BollingerBandsUpperIndicator extends CachedIndicator {
  /// Initializes.
  ///
  ///  [bbm]       the middle band Indicator. Typically an SMAIndicator is
  ///                  used.
  ///  [deviation] the deviation above and below the middle, factored by k.
  ///                  Typically a StandardDeviationIndicator is used.
  ///  [k]         the scaling factor to multiply the deviation by. Typically 2
  BollingerBandsUpperIndicator(this.bbm, this.deviation, {this.k = 2})
      : super.fromIndicator(deviation);

  /// Deviation indicator
  final Indicator deviation;

  /// The middle indicator of the BollingerBand
  final Indicator bbm;

  /// Default is 2.
  final double k;

  @override
  Tick calculate(int index) => Tick(
        epoch: getEpochOfIndex(index),
        quote:
            bbm.getValue(index).quote + (deviation.getValue(index).quote * k),
      );
}
