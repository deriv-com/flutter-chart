import 'package:deriv_chart/src/models/candle.dart';

import '../cached_indicator.dart';

class HighValueIndicator extends CachedIndicator {
  HighValueIndicator(List<Candle> candles) : super(candles);

  @override
  double calculate(int index) => candles[index].high;
}
