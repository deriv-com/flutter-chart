import 'package:deriv_chart/src/logic/indicators/indicator.dart';
import 'package:deriv_chart/src/models/candle.dart';
import 'package:deriv_chart/src/models/ohlc.dart';
import 'package:deriv_chart/src/models/tick.dart';

/// A helper indicator to get the high value of a list of [Candle]
class HighValueIndicator extends Indicator {
  /// Initializes
  HighValueIndicator(List<OHLC> entries) : super(entries);

  @override
  Tick getValue(int index) =>
      Tick(epoch: getEpochOfIndex(index), quote: entries[index].high);
}
