import 'package:deriv_chart/src/models/tick.dart';

import '../../indicator.dart';

/// A helper indicator to get the open value of a list of [Tick]
class OpenValueIndicator extends Indicator {
  /// Initializes
  OpenValueIndicator(List<Tick> entries) : super(entries);

  @override
  Tick getValue(int index) =>
      Tick(epoch: getEpochOfIndex(index), quote: entries[index].open);
}
