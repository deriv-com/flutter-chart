import 'package:deriv_chart/src/logic/indicators/cached_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/mma_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/tri_indicator.dart';
import 'package:deriv_chart/src/models/ohlc.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:flutter/foundation.dart';

/// Average true range indicator.
class ATRIndicator extends CachedIndicator {
  /// Initializes an average true range indicator.
  ATRIndicator(
    List<OHLC> entries, {
    @required int period,
  })  : _averageTrueRangeIndicator = MMAIndicator(TRIndicator(entries), period),
        super(entries);

  final MMAIndicator _averageTrueRangeIndicator;

  @override
  Tick calculate(int index) => _averageTrueRangeIndicator.getValue(index);
}
