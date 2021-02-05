import 'package:deriv_chart/src/models/candle.dart';
import 'package:deriv_chart/src/models/ohlc.dart';
import 'package:deriv_chart/src/models/tick.dart';

import '../../indicator.dart';

/// A helper indicator to get the low value of a list of [Candle]
class LowValueIndicator extends Indicator {
  /// Initializes
  LowValueIndicator(List<OHLC> entries) : super(entries);

  @override
  Tick getValue(int index) =>
      Tick(epoch: getEpochOfIndex(index), quote: entries[index].low);
}
