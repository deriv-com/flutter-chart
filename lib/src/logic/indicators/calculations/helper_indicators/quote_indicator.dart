import 'package:deriv_chart/src/models/tick.dart';

import '../../cached_indicator.dart';

/// A helper indicator to get the quote values of a list of [Tick].
class QuoteIndicator extends CachedIndicator<Tick> {
  /// Initializes
  QuoteIndicator(List<Tick> candles) : super(candles);

  @override
  Tick calculate(int index) =>
      Tick(epoch: entries[index].epoch, quote: entries[index].quote);
}
