import 'package:deriv_chart/src/models/candle.dart';
import 'package:deriv_chart/src/models/tick.dart';

import '../../cached_indicator.dart';

/// A helper indicator to get the high value of a list of [Candle]
class HighValueIndicator extends CachedIndicator<Candle> {
  /// Initializes
  HighValueIndicator(List<Candle> candles) : super(candles);

  @override
  Tick calculate(int index) =>
      Tick(epoch: entries[index].epoch, quote: entries[index].high);
}
