// **********
// ** NOTE ** Not completed yet. In progress...
// **********

import 'package:deriv_chart/src/models/candle.dart';
import 'package:deriv_chart/src/models/tick.dart';

import '../indicator.dart';
import '../cached_indicator.dart';
import 'helper_indicators/high_value_inidicator.dart';
import 'helper_indicators/low_value_indicator.dart';
import 'highest_value_indicator.dart';
import 'lowest_value_indicator.dart';

/// Ichimoku abstract line indicator
class AbstractIchimokuLineIndicator extends CachedIndicator {
  /// Initializes.
  ///
  /// [entries]   the data
  /// [barCount] Bar count
  AbstractIchimokuLineIndicator(List<Candle> entries, int barCount)
      : _periodHigh =
            HighestValueIndicator(HighValueIndicator(entries), barCount),
        _periodLow = LowestValueIndicator(LowValueIndicator(entries), barCount),
        super(entries);

  /// The period high
  final Indicator _periodHigh;

  /// The period low
  final Indicator _periodLow;

  @override
  Tick calculate(int index) => Tick(
        epoch: entries[index].epoch,
        quote: _periodHigh.getValue(index).quote +
            _periodLow.getValue(index).quote / 2,
      );
}
