import 'package:deriv_chart/src/models/candle.dart';
import 'package:deriv_chart/src/models/tick.dart';

import '../cached_indicator.dart';

class CloseValueIndicator extends CachedIndicator<Candle> {
  CloseValueIndicator(List<Candle> candles) : super(candles);

  @override
  Tick calculate(int index) =>
      Tick(epoch: candles[index].epoch, quote: candles[index].close);
}

class QuoteIndicator extends CachedIndicator<Tick> {
  QuoteIndicator(List<Tick> candles) : super(candles);

  @override
  Tick calculate(int index) =>
      Tick(epoch: candles[index].epoch, quote: candles[index].quote);
}
