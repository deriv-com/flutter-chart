import 'dart:math';

import '../../models/tick.dart';
import '../cached_indicator.dart';
import '../indicator.dart';
import 'helper_indicators/difference_indicator.dart';
import 'helper_indicators/multiplier_indicator.dart';
import 'wma_indicator.dart';

/// Hull Moving Average indicator
class HMAIndicator extends CachedIndicator {
  /// Initializes
  HMAIndicator(Indicator indicator, this.period)
      : _sqrtWma = WMAIndicator(
          DifferenceIndicator(
            MultiplierIndicator(WMAIndicator(indicator, period ~/ 2), 2),
            WMAIndicator(indicator, period),
          ),
          sqrt(period).toInt(),
        ),
        super.fromIndicator(indicator);

  /// Moving average bar count
  final int period;

  final WMAIndicator _sqrtWma;

  @override
  Tick calculate(int index) => _sqrtWma.getValue(index);
}
