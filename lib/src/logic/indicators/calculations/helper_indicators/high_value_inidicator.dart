import 'package:deriv_chart/src/models/candle.dart';
import 'package:deriv_chart/src/models/tick.dart';

import '../cached_indicator.dart';

class HighValueIndicator extends CachedIndicator {
  HighValueIndicator(List<Candle> candles) : super(candles);

  @override
  Tick calculate(int index) =>
      Tick(epoch: candles[index].epoch, quote: candles[index].high);
}
