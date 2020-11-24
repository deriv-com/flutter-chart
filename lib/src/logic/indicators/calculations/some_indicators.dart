import 'package:deriv_chart/src/models/candle.dart';
import 'package:deriv_chart/src/models/tick.dart';

import '../indicator.dart';
import 'cached_indicator.dart';
import 'helper_indicators/high_value_inidicator.dart';
import 'helper_indicators/low_value_indicator.dart';
import 'highest_value_indicator.dart';
import 'lowest_value_indicator.dart';

class AbstractIchimokuLineIndicator extends CachedIndicator {
  /// The period high
  final Indicator _periodHigh;

  /// The period low
  final Indicator _periodLow;

  /// Initializes.
  ///
  /// [candles]   the data
  /// [barCount] the time frame
  AbstractIchimokuLineIndicator(List<Candle> candles, int barCount)
      : _periodHigh =
            HighestValueIndicator(HighValueIndicator(candles), barCount),
        _periodLow = LowestValueIndicator(LowValueIndicator(candles), barCount),
        super(candles);

  @override
  Tick calculate(int index) => Tick(
        epoch: entries[index].epoch,
        quote: _periodHigh.getValue(index).quote +
            _periodLow.getValue(index).quote / 2,
      );
}
