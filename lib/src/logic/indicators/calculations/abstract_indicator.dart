import 'package:deriv_chart/src/models/candle.dart';
import 'package:deriv_chart/src/models/tick.dart';

import '../indicator.dart';

/// Bass class of all indicators.
abstract class AbstractIndicator<T extends Tick> implements Indicator {
  /// Initializes
  AbstractIndicator(this.candles);

  /// List of data
  final List<T> candles;

  /// Gets the epoch on the give [index]
  int getEpochOfIndex(int index) => candles[index].epoch;
}
