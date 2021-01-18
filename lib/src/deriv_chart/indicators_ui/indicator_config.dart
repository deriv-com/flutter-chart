import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/helper_indicators/close_value_inidicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/helper_indicators/high_value_inidicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/helper_indicators/hl2_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/helper_indicators/low_value_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/helper_indicators/open_value_indicator.dart';
import 'package:deriv_chart/src/models/tick.dart';

import 'callbacks.dart';

/// Indicator config
abstract class IndicatorConfig {
  /// Initializes
  const IndicatorConfig();

  /// List of all [FieldIndicatorBuilder] types that an `Indicator` supports.
  static final Map<String, FieldIndicatorBuilder> supportedFieldTypes =
      <String, FieldIndicatorBuilder>{
    'close': (List<Tick> ticks) => CloseValueIndicator(ticks),
    'high': (List<Tick> ticks) => HighValueIndicator(ticks),
    'low': (List<Tick> ticks) => LowValueIndicator(ticks),
    'open': (List<Tick> ticks) => OpenValueIndicator(ticks),
    'Hl/2': (List<Tick> ticks) => HL2Indicator(ticks),
    // TODO(Ramin): Add also hlc3, hlcc4, ohlc4 Indicators.
  };

  /// Returns the chart serries of the given [ticks].
  Series getSeries(List<Tick> ticks);
}
