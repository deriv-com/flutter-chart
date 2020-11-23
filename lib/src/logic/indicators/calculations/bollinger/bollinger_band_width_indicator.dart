import 'package:deriv_chart/src/models/tick.dart';

import '../cached_indicator.dart';
import 'bollinger_bands_lower_indicator.dart';
import 'bollinger_bands_middle_indicator.dart';
import 'bollinger_bands_upper_indicator.dart';

///
/// Bollinger BandWidth indicator.
///

class BollingerBandWidthIndicator extends CachedIndicator {
  final BollingerBandsUpperIndicator bbu;
  final BollingerBandsMiddleIndicator bbm;
  final BollingerBandsLowerIndicator bbl;
  final double hundred;

  ///
  /// Constructor.
  ///
  /// bbu the upper band Indicator.
  /// bbm the middle band Indicator. Typically an SMAIndicator is used.
  /// bbl the lower band Indicator.
  BollingerBandWidthIndicator(this.bbu, this.bbm, this.bbl,
      {this.hundred = 100})
      : super(bbm.candles);

  @override
  Tick calculate(int index) {
    return Tick(
      epoch: getEpochOfIndex(index),
      quote: ((bbu.getValue(index).quote - bbl.getValue(index).quote) /
              bbm.getValue(index).quote) *
          hundred,
    );
  }
}
