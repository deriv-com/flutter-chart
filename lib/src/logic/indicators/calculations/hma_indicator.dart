import 'dart:math';

import 'package:deriv_chart/src/models/tick.dart';

import '../cached_indicator.dart';
import '../indicator.dart';
import 'helper_indicators/difference_indicator.dart';
import 'helper_indicators/multiplier_indicator.dart';
import 'wma_indicator.dart';

/// Hull Moving Average indicator
class HMAIndicator extends CachedIndicator {
  /// Initializes
  HMAIndicator(Indicator indicator, this.barCount)
      : _sqrtWma = WMAIndicator(
          DifferenceIndicator(
            MultiplierIndicator(WMAIndicator(indicator, barCount ~/ 2), 2),
            WMAIndicator(indicator, barCount),
          ),
          sqrt(barCount).toInt(),
        ),
        super.fromIndicator(indicator);

  /// Moving average bar count
  final int barCount;

  WMAIndicator _sqrtWma;

  @override
  Tick calculate(int index) => _sqrtWma.getValue(index);
}
