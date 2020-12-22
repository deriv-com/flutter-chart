import 'package:deriv_chart/src/models/tick.dart';

import '../../indicator.dart';
import '../../cached_indicator.dart';

/// Bollinger bands middle indicator
class BollingerBandsMiddleIndicator extends CachedIndicator<Tick> {
  /// [indicator] the indicator that gives the values of the middle band
  BollingerBandsMiddleIndicator(this.indicator)
      : super.fromIndicator(indicator);

  /// Indicator
  final Indicator<Tick> indicator;

  @override
  Tick calculate(int index) => indicator.getValue(index);
}
