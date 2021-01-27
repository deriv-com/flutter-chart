import 'package:deriv_chart/src/logic/indicators/calculations/ichimoku/ichimoku_line_indicator.dart';
import 'package:deriv_chart/src/models/ohlc.dart';

/// An `indicator` to calculate average of `Highest High` and `Lowest Low` in the last given number of [period]s which is set to `9` by default.
class IchimokuConversionLineIndicator extends IchimokuLineIndicator {
  /// Initializes an [IchimokuConversionLineIndicator].
  IchimokuConversionLineIndicator(
    List<OHLC> entries, {
    int period = 9,
  }) : super(entries, period: period);
}
