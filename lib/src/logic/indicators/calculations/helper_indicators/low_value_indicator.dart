import 'package:deriv_chart/src/models/candle.dart';

import '../cached_indicator.dart';

class LowValueIndicator extends CachedIndicator {
  LowValueIndicator(List<Candle> candles) : super(candles);

  @override
  double calculate(int index) => candles[index].low;
}

class CloseValueIndicator extends CachedIndicator {
  CloseValueIndicator(List<Candle> candles) : super(candles);

  @override
  double calculate(int index) => candles[index].close;
}
