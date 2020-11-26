import 'package:deriv_chart/src/logic/indicators/abstract_indicator.dart';
import 'package:deriv_chart/src/models/candle.dart';
import 'package:deriv_chart/src/models/tick.dart';

/// A helper indicator to get the high value of a list of [Candle]
class HighValueIndicator extends AbstractIndicator<Candle> {
  /// Initializes
  HighValueIndicator(List<Candle> candles) : super(candles);

  @override
  Tick getValue(int index) =>
      Tick(epoch: getEpochOfIndex(index), quote: entries[index].high);
}
