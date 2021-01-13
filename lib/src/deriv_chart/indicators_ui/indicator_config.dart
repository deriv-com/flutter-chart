import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/helper_indicators/close_value_inidicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/helper_indicators/high_value_inidicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/helper_indicators/hl2_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/helper_indicators/hlc3_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/helper_indicators/hlcc4_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/helper_indicators/low_value_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/helper_indicators/ohlc4_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/helper_indicators/open_value_indicator.dart';
import 'package:deriv_chart/src/models/tick.dart';

import 'callbacks.dart';

/// Indicator config
abstract class IndicatorConfig {
  /// Initializes
  const IndicatorConfig();

  static final Map<String, FieldIndicatorBuilder> supportedFieldTypes =
      <String, FieldIndicatorBuilder>{
    'close': (List<Tick> ticks) => CloseValueIndicator(ticks),
    'high': (List<Tick> ticks) => HighValueIndicator(ticks),
    'low': (List<Tick> ticks) => LowValueIndicator(ticks),
    'open': (List<Tick> ticks) => OpenValueIndicator(ticks),
    'Hl/2': (List<Tick> ticks) => HL2Indicator(ticks),
    'HlC/3': (List<Tick> ticks) => HLC3Indicator(ticks),
    'HlCC/4': (List<Tick> ticks) => HLCC4Indicator(ticks),
    'OHlC/4': (List<Tick> ticks) => OHLC4Indicator(ticks),
  };

  Series getSeries(List<Tick> ticks);
}
