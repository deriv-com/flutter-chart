import 'package:deriv_technical_analysis/src/models/ohlc.dart';
import 'package:deriv_technical_analysis/src/models/tick.dart';

import '../../indicator.dart';

/// A helper indicator to get the high value of a list of [OHLC]
class HighValueIndicator extends Indicator {
  /// Initializes
  HighValueIndicator(List<OHLC> entries) : super(entries);

  @override
  Tick getValue(int index) =>
      Tick(epoch: getEpochOfIndex(index), quote: entries[index].high);
}
