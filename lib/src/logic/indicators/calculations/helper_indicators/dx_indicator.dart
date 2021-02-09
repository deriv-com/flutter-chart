import 'package:deriv_chart/src/logic/indicators/cached_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/adx/negative_directional_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/adx/positive_directional_indicaor.dart';
import 'package:deriv_chart/src/models/ohlc.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:flutter/foundation.dart';

/// Directional movement line Indicator.
class DXIndicator extends CachedIndicator {
  /// Initializes a Directional movement line Indicator.
  DXIndicator(
    List<OHLC> entries, {
    @required int period,
  })  : _positiveDIIndicator =
            PositiveDirectionalIndicator(entries, period: period),
        _negativeDIIndicator =
            NegativeDirectionalIndicator(entries, period: period),
        super(entries);

  final PositiveDirectionalIndicator _positiveDIIndicator;
  final NegativeDirectionalIndicator _negativeDIIndicator;

  @override
  Tick calculate(int index) {
    final double pdiValue = _positiveDIIndicator.getValue(index).quote;
    final double ndiValue = _negativeDIIndicator.getValue(index).quote;
    final double sumDI = pdiValue + ndiValue;
    final double diffDI = (pdiValue - ndiValue).abs();
    if ((pdiValue + ndiValue) == 0) {
      return Tick(epoch: getEpochOfIndex(index), quote: 0);
    }
    return Tick(epoch: getEpochOfIndex(index), quote: (diffDI / sumDI) * 100);
  }
}
