import 'package:deriv_chart/src/models/tick.dart';

import '../../indicator.dart';
import '../cached_indicator.dart';
import 'bollinger_bands_middle_indicator.dart';

///
/// Buy - Occurs when the price line crosses from below to above the Lower
/// Bollinger Band. Sell - Occurs when the price line crosses from above to below
/// the Upper Bollinger Band.
///
class BollingerBandsUpperIndicator extends CachedIndicator {
  final Indicator deviation;

  final BollingerBandsMiddleIndicator bbm;

  final double k;

  ///
  /// Initializes.
  ///
  ///  [bbm]       the middle band Indicator. Typically an SMAIndicator is
  ///                  used.
  ///  [deviation] the deviation above and below the middle, factored by k.
  ///                  Typically a StandardDeviationIndicator is used.
  ///  [k]         the scaling factor to multiply the deviation by. Typically 2
  BollingerBandsUpperIndicator(this.bbm, this.deviation, {this.k = 2})
      : super.fromIndicator(deviation);

  @override
  Tick calculate(int index) => Tick(
        epoch: getEpochOfIndex(index),
        quote:
            bbm.getValue(index).quote + (deviation.getValue(index).quote * k),
      );
}
