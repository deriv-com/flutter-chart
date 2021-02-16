import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';
import 'package:deriv_technical_analysis/src/indicators/calculations/helper_indicators/dx_indicator.dart';
import 'package:deriv_technical_analysis/src/indicators/calculations/mma_indicator.dart';
import 'package:flutter/foundation.dart';

/// Average Directional Movement. Part of the Directional Movement System.
class ADXIndicator<T extends IndicatorResult> extends CachedIndicator<T> {
  /// Initializes an Average Directional Movement. Part of the Directional Movement System.
  ADXIndicator(
    IndicatorDataInput entries, {
    @required int diPeriod,
    @required int adxPeriod,
  })  : _averageDXIndicator = MMAIndicator<T>(
            DXIndicator<T>(entries, period: diPeriod), adxPeriod),
        super(entries);

  final MMAIndicator<T> _averageDXIndicator;

  @override
  T calculate(int index) => _averageDXIndicator.getValue(index);
}
