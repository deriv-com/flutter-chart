import 'package:deriv_technical_analysis/src/models/ohlc.dart';
import 'package:deriv_technical_analysis/src/models/tick.dart';

import '../../indicator.dart';

/// A helper indicator to get the [(H + L+ C) / 3] value of a list of [Tick]
class HLC3Indicator extends Indicator {
  /// Initializes
  HLC3Indicator(List<OHLC> entries) : super(entries);

  @override
  Tick getValue(int index) {
    final Tick entry = entries[index];
    return Tick(
      epoch: getEpochOfIndex(index),
      quote: (entry.high + entry.low + entry.close) / 3,
    );
  }
}
