import 'package:deriv_chart/src/models/tick.dart';

import '../cached_indicator.dart';

class QuoteIndicator extends CachedIndicator<Tick> {
  QuoteIndicator(List<Tick> candles) : super(candles);

  @override
  Tick calculate(int index) =>
      Tick(epoch: candles[index].epoch, quote: candles[index].quote);
}
