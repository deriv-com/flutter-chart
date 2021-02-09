import 'package:deriv_chart/src/logic/indicators/cached_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/atr_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/mma_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/negative_dm_indicator.dart';
import 'package:deriv_chart/src/models/ohlc.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:flutter/foundation.dart';

/// Negative Directional indicator. Part of the Directional Movement System.
class NegativeDirectionalIndicator extends CachedIndicator {
  ///Initializes a Negative Directional indicator.
  NegativeDirectionalIndicator(List<OHLC> entries, {@required int period})
      : _avgMinusDMIndicator =
            MMAIndicator(NegativeDMIndicator(entries), period),
        _atrIndicator = ATRIndicator(entries, period: period),
        super(entries);

  final MMAIndicator _avgMinusDMIndicator;
  final ATRIndicator _atrIndicator;

  @override
  Tick calculate(int index) => Tick(
      epoch: getEpochOfIndex(index),
      quote: (_avgMinusDMIndicator.getValue(index).quote /
              _atrIndicator.getValue(index).quote) *
          100);
}
