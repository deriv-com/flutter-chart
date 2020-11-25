import 'package:deriv_chart/src/models/candle.dart';
import 'package:deriv_chart/src/models/tick.dart';

import '../../cached_indicator.dart';

class LowValueIndicator extends CachedIndicator<Candle> {
  LowValueIndicator(List<Candle> candles) : super(candles);

  @override
  Tick calculate(int index) =>
      Tick(epoch: entries[index].epoch, quote: entries[index].low);
}
