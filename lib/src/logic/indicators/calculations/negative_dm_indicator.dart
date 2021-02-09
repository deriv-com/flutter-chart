import 'package:deriv_chart/src/logic/indicators/cached_indicator.dart';
import 'package:deriv_chart/src/models/ohlc.dart';
import 'package:deriv_chart/src/models/tick.dart';

/// Negative Directional Movement indicator.
class NegativeDMIndicator extends CachedIndicator {
  ///Intializes a Negative Directional Movement indicator.
  NegativeDMIndicator(List<OHLC> entries) : super(entries);

  @override
  Tick calculate(int index) {
    final Tick zeroTick = Tick(epoch: getEpochOfIndex(index), quote: 0);
    if (index == 0) {
      return zeroTick;
    }
    final Tick prevTick = entries[index - 1];
    final Tick currentTick = entries[index];

    final double upMove = currentTick.high - prevTick.high;
    final double downMove = prevTick.low - currentTick.low;
    if (downMove > upMove && downMove > 0) {
      return Tick(epoch: getEpochOfIndex(index), quote: downMove);
    } else {
      return zeroTick;
    }
  }
}
