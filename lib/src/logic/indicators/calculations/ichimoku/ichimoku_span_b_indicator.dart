import 'package:deriv_chart/src/logic/indicators/calculations/ichimoku/ichimoku_line_indicator.dart';
import 'package:deriv_chart/src/models/ohlc.dart';

/// An `indicator` to calculate average of `Highest High` and `Lowest Low` in the last given number of [period]s which is set to `52` by default.
class IchimokuSpanBIndicator extends IchimokuLineIndicator {
  /// Initializes an [IchimokuSpanBIndicator].
  IchimokuSpanBIndicator(
    List<OHLC> entries, {
    int period = 52,
  }) : super(entries, period: period);
}
