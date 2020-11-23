import 'dart:math';

import 'package:deriv_chart/src/models/tick.dart';

import '../indicator.dart';
import 'cached_indicator.dart';
import 'helper_indicators/difference_indicator.dart';
import 'helper_indicators/multiplier_indicator.dart';
import 'wma_indicator.dart';

/// Hull Moving Average
class HMAIndicator extends CachedIndicator {
  HMAIndicator(Indicator indicator, this.barCount)
      : sqrtWma = WMAIndicator(
          DifferenceIndicator(
            MultiplierIndicator(WMAIndicator(indicator, barCount ~/ 2), 2),
            WMAIndicator(indicator, barCount),
          ),
          sqrt(barCount).toInt(),
        ),
        super.fromIndicator(indicator);

  final int barCount;

  WMAIndicator sqrtWma;

  @override
  Tick calculate(int index) => sqrtWma.getValue(index);
}
