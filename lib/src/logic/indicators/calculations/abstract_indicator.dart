import 'package:deriv_chart/src/models/candle.dart';

import '../indicator.dart';

/// Bass class of all indicators.
abstract class AbstractIndicator implements Indicator {
  final List<Candle> candles;

  AbstractIndicator(this.candles);

  int getEpochOfIndex(int index) => candles[index].epoch;
}
