import 'package:deriv_chart/src/models/candle.dart';
import 'package:deriv_chart/src/models/tick.dart';

import '../../abstract_indicator.dart';

/// A helper indicator to get the low value of a list of [Candle]
class LowValueIndicator extends AbstractIndicator<Tick> {
  /// Initializes
  LowValueIndicator(List<Tick> entries) : super(entries);

  @override
  Tick getValue(int index) =>
      Tick(epoch: getEpochOfIndex(index), quote: entries[index].low);
}
