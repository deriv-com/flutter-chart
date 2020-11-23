import 'package:deriv_chart/src/models/candle.dart';
import 'package:deriv_chart/src/models/tick.dart';

import '../indicator.dart';

/// Bass class of all indicators.
abstract class AbstractIndicator<T extends Tick> implements Indicator {
  final List<T> candles;

  AbstractIndicator(this.candles);

  int getEpochOfIndex(int index) => candles[index].epoch;
}
