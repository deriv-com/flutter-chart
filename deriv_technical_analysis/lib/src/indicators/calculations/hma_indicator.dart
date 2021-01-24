import 'dart:math';

import 'package:deriv_technical_analysis/src/models/models.dart';

import '../cached_indicator.dart';
import '../indicator.dart';
import 'helper_indicators/difference_indicator.dart';
import 'helper_indicators/multiplier_indicator.dart';
import 'wma_indicator.dart';

/// Hull Moving Average indicator
class HMAIndicator<T extends Result> extends CachedIndicator<T> {
  /// Initializes
  HMAIndicator(Indicator<T> indicator, this.period)
      : _sqrtWma = WMAIndicator<T>(
          DifferenceIndicator<T>(
            MultiplierIndicator<T>(WMAIndicator<T>(indicator, period ~/ 2), 2),
            WMAIndicator<T>(indicator, period),
          ),
          sqrt(period).toInt(),
        ),
        super.fromIndicator(indicator);

  /// Moving average bar count
  final int period;

  final WMAIndicator<T> _sqrtWma;

  @override
  T calculate(int index) => _sqrtWma.getValue(index);
}
