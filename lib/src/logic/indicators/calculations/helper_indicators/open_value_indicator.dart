import 'package:deriv_chart/src/models/candle.dart';
import 'package:deriv_chart/src/models/tick.dart';

import '../../abstract_indicator.dart';

/// A helper indicator to get the open value of a list of [Tick]
class OpenValueIndicator extends AbstractIndicator<Tick> {
  /// Initializes
  OpenValueIndicator(List<Tick> entries) : super(entries);

  @override
  Tick getValue(int index) =>
      Tick(epoch: getEpochOfIndex(index), quote: entries[index].open);
}
