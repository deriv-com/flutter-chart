import 'package:deriv_chart/src/models/tick.dart';

import '../../cached_indicator.dart';
import 'bollinger_bands_lower_indicator.dart';
import 'bollinger_bands_middle_indicator.dart';
import 'bollinger_bands_upper_indicator.dart';

/// Bollinger Band Width indicator.
class BollingerBandWidthIndicator extends CachedIndicator {
  /// The upper band Indicator.
  final BollingerBandsUpperIndicator bbu;

  /// The middle band Indicator. Typically an SMAIndicator is used.
  final BollingerBandsMiddleIndicator bbm;

  /// The lower band Indicator.
  final BollingerBandsLowerIndicator bbl;

  /// Typically is 100.
  final double hundred;

  /// Initializes.
  ///
  /// [bbu] the upper band Indicator.
  /// [bbm] the middle band Indicator. Typically an SMAIndicator is used.
  /// [bbl] the lower band Indicator.
  BollingerBandWidthIndicator(
    this.bbu,
    this.bbm,
    this.bbl, {
    this.hundred = 100,
  }) : super(bbm.entries);

  @override
  Tick calculate(int index) => Tick(
        epoch: getEpochOfIndex(index),
        quote: ((bbu.getValue(index).quote - bbl.getValue(index).quote) /
                bbm.getValue(index).quote) *
            hundred,
      );
}
