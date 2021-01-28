import 'package:deriv_chart/src/logic/indicators/calculations/helper_indicators/close_value_inidicator.dart';
import 'package:deriv_chart/src/models/ohlc.dart';

/// An `indicator` to calculate the `close` value the given number of offsets ago.
class IchimokuLaggingSpanIndicator extends CloseValueIndicator {
  /// Initializes an [IchimokuLaggingSpanIndicator].
  IchimokuLaggingSpanIndicator(
    List<OHLC> entries,
  ) : super(entries);
}
