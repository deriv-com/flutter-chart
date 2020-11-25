import 'package:deriv_chart/src/models/candle.dart';
import 'package:deriv_chart/src/models/tick.dart';

import '../../abstract_indicator.dart';

/// A helper indicator to get the low value of a list of [Candle]
class LowValueIndicator extends AbstractIndicator<Candle> {
  /// Initializes
  LowValueIndicator(List<Candle> candles) : super(candles);

  @override
  Tick getValue(int index) =>
      Tick(epoch: entries[index].epoch, quote: entries[index].low);
}
