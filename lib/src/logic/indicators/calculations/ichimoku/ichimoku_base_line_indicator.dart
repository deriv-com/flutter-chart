import 'package:deriv_chart/src/logic/indicators/calculations/ichimoku/ichimoku_line_indicator.dart';
import 'package:deriv_chart/src/models/ohlc.dart';

/// An `indicator` to calculate average of `Highest High` and `Lowest Low` in the last given number of [period]s which is set to `26` by default.
class IchimokuBaseLineIndicator extends IchimokuLineIndicator {
  /// Initializes an [IchimokuBaseLineIndicator].
  IchimokuBaseLineIndicator(
    List<OHLC> entries, {
    int period = 26,
  }) : super(entries, period: period);
}
