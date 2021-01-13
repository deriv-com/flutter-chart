import 'package:deriv_chart/src/models/tick.dart';

import '../../indicator.dart';

/// A helper indicator to get the [(H + L+ 2* C) / 4] value of a list of [Tick]
class HLCC4Indicator extends Indicator {
  /// Initializes
  HLCC4Indicator(List<Tick> entries) : super(entries);

  @override
  Tick getValue(int index) {
    final Tick entry = entries[index];
    return Tick(
      epoch: getEpochOfIndex(index),
      quote: (entry.high + entry.low + 2 * entry.close) / 4,
    );
  }
}
