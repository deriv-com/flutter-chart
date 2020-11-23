import 'package:deriv_chart/src/logic/indicators/indicator.dart';
import 'package:deriv_chart/src/models/tick.dart';

import '../cached_indicator.dart';

/// Buy - Occurs when the price line crosses from below to above the Lower
/// Bollinger Band. Sell - Occurs when the price line crosses from above to below
/// the Upper Bollinger Band.
class BollingerBandsMiddleIndicator extends CachedIndicator {
  final Indicator indicator;

  /// [indicator] the indicator that gives the values of the middle band
  BollingerBandsMiddleIndicator(this.indicator)
      : super.fromIndicator(indicator);

  @override
  Tick calculate(int index) => indicator.getValue(index);
}
