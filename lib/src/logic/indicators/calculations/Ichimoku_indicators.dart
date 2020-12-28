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
class AbstractIchimokuLineIndicator extends CachedIndicator<Tick> {
  /// Initializes.
  ///
  /// [entries]   the data
  /// [period] Bar count
  AbstractIchimokuLineIndicator(List<Candle> entries, int period)
      : _periodHigh =
            HighestValueIndicator(HighValueIndicator(entries), period),
        _periodLow = LowestValueIndicator(LowValueIndicator(entries), period),
        super(entries);

  /// The period high
  final Indicator<Tick> _periodHigh;

  /// The period low
  final Indicator<Tick> _periodLow;

  @override
  Tick calculate(int index) => Tick(
        epoch: getEpochOfIndex(index),
        quote: _periodHigh.getValue(index).quote +
            _periodLow.getValue(index).quote / 2,
      );
}
