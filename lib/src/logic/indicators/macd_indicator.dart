import 'package:deriv_chart/src/logic/indicators/cached_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/ema_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/indicator.dart';
import 'package:deriv_chart/src/models/tick.dart';

/// Moving Average Convergance Divergence Indicator
class MACDIndicator extends CachedIndicator {
  /// Creates a  Moving average convergance divergance indicator from a given indicator,
  /// with short term ema set to `12` periods and long term ema set to `26` periods as default.
  MACDIndicator.fromIndicator(
    Indicator indicator, {
    int shortBarcount = 12,
    int longBarCount = 26,
  })  : assert(shortBarcount <= longBarCount),
        _shortTermEma = EMAIndicator(indicator, shortBarcount),
        _longTermEma = EMAIndicator(indicator, longBarCount),
        super.fromIndicator(indicator);

  final EMAIndicator _shortTermEma;
  final EMAIndicator _longTermEma;

  @override
  Tick calculate(int index) => Tick(
        epoch: getEpochOfIndex(index),
        quote: _shortTermEma.getValue(index).quote -
            _longTermEma.getValue(index).quote,
      );
}
