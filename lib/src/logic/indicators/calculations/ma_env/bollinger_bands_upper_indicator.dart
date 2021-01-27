import 'package:deriv_chart/src/models/tick.dart';

import '../../cached_indicator.dart';
import '../../indicator.dart';

/// Bollinger bands upper indicator
class MAEnvUpperIndicator extends CachedIndicator {
  /// Initializes.
  ///
  ///  [bbm]       the middle band Indicator. Typically an SMAIndicator is
  ///                  used.
  ///  [deviation] the deviation above and below the middle, factored by k.
  ///                  Typically a StandardDeviationIndicator is used.
  ///  [k]         the scaling factor to multiply the deviation by. Typically 2
  MAEnvUpperIndicator(this.bbm, this.shift, )
      : super.fromIndicator(bbm);


  /// The middle indicator of the BollingerBand
  final Indicator bbm;

  final int shift;

  @override
  Tick calculate(int index) => Tick(
        epoch: getEpochOfIndex(index),
        quote:
            bbm.getValue(index).quote * (1 + (shift/100)),
      );
}
