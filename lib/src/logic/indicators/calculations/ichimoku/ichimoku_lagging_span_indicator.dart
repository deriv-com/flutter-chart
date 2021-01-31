import 'package:deriv_chart/src/logic/indicators/cached_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/helper_indicators/close_value_inidicator.dart';
import 'package:deriv_chart/src/models/ohlc.dart';
import 'package:deriv_chart/src/models/tick.dart';

/// An `indicator` to calculate the `close` value the given number of offsets ago.
class IchimokuLaggingSpanIndicator extends CachedIndicator {
  /// Initializes an [IchimokuLaggingSpanIndicator].
  IchimokuLaggingSpanIndicator(
    List<OHLC> entries,
  )   : _closeValueIndicator = CloseValueIndicator(entries),
        super(entries);

  @override
  Tick calculate(int index) => _closeValueIndicator.getValue(index);

  final CloseValueIndicator _closeValueIndicator;
}
