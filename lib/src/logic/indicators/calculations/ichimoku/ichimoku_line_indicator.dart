import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/logic/indicators/cached_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/helper_indicators/high_value_inidicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/helper_indicators/low_value_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/highest_value_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/lowest_value_indicator.dart';
import 'package:deriv_chart/src/models/ohlc.dart';

/// An abstract class for calculating (`Highest High` + `Lowest Low`) / 2 in the given passed [period]s.
abstract class IchimokuLineIndicator extends CachedIndicator {
  /// Initializes an [IchimokuLineIndicator].
  IchimokuLineIndicator(
    List<OHLC> entries, {
    this.period,
  })  : _lowestValueIndicator =
            LowestValueIndicator(LowValueIndicator(entries), period),
        _highestValueIndicator =
            HighestValueIndicator(HighValueIndicator(entries), period),
        super(entries);

  @override
  Tick calculate(int index) {
    final double lineQuote = (_highestValueIndicator.getValue(index).quote +
            _lowestValueIndicator.getValue(index).quote) /
        2;
    return Tick(epoch: getEpochOfIndex(index), quote: lineQuote);
  }

  /// Number of periods to calculate `Highest High` and `Lowest Low` from.
  final int period;

  final LowestValueIndicator _lowestValueIndicator;

  final HighestValueIndicator _highestValueIndicator;
}
