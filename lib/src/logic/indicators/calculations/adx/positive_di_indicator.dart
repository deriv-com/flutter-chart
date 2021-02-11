import 'package:deriv_chart/src/logic/indicators/cached_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/atr_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/helper_indicators/positive_dm_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/mma_indicator.dart';
import 'package:deriv_chart/src/models/ohlc.dart';
import 'package:deriv_chart/src/models/tick.dart';

/// Negative Directional indicator. Part of the Directional Movement System.
class PositiveDIIndicator extends CachedIndicator {
  /// Initializes Negative Directional indicator.
  PositiveDIIndicator(
    List<OHLC> entries, {
    int period = 14,
  })  : _avgPlusDMIndicator =
            MMAIndicator(PositiveDMIndicator(entries), period),
        _atrIndicator = ATRIndicator(entries, period: period),
        super(entries);

  final MMAIndicator _avgPlusDMIndicator;
  final ATRIndicator _atrIndicator;

  @override
  Tick calculate(int index) => Tick(
      epoch: getEpochOfIndex(index),
      quote: (_avgPlusDMIndicator.getValue(index).quote /
              _atrIndicator.getValue(index).quote) *
          100);
}
