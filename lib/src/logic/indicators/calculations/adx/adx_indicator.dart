import 'package:deriv_chart/src/logic/indicators/cached_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/helper_indicators/dx_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/mma_indicator.dart';
import 'package:deriv_chart/src/models/ohlc.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:flutter/foundation.dart';

/// Average Directional Movement. Part of the Directional Movement System.
class ADXIndicator extends CachedIndicator {
  /// Initializes an Average Directional Movement. Part of the Directional Movement System.
  ADXIndicator(
    List<OHLC> entries, {
    @required int diPeriod,
    @required int adxPeriod,
  })  : _averageDXIndicator =
            MMAIndicator(DXIndicator(entries, period: diPeriod), adxPeriod),
        super(entries);

  final MMAIndicator _averageDXIndicator;

  @override
  Tick calculate(int index) => _averageDXIndicator.getValue(index);
}
