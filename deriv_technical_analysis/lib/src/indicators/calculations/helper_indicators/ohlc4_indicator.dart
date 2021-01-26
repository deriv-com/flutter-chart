import 'package:deriv_technical_analysis/src/models/ohlc.dart';
import 'package:deriv_technical_analysis/src/models/tick.dart';

import '../../indicator.dart';

/// A helper indicator to get the [(O+ H + L+ C) / 4] value of a list of [Tick]
class OHLC4Indicator extends Indicator {
  /// Initializes
  OHLC4Indicator(List<OHLC> entries) : super(entries);

  @override
  Tick getValue(int index) {
    final Tick entry = entries[index];
    return Tick(
      epoch: getEpochOfIndex(index),
      quote: (entry.open + entry.high + entry.low + entry.close) / 4,
    );
  }
}
