import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/models/IndicatorInput.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';

import 'callbacks.dart';

/// Indicator config
abstract class IndicatorConfig {
  /// Initializes
  const IndicatorConfig();

  static final Map<String, FieldIndicatorBuilder> supportedFieldTypes =
      <String, FieldIndicatorBuilder>{
    'close': (List<Tick> ticks) =>
        CloseValueIndicator<Tick>(IndicatorInput(ticks)),
    'high': (List<Tick> ticks) =>
        HighValueIndicator<Tick>(IndicatorInput(ticks)),
    'low': (List<Tick> ticks) => LowValueIndicator<Tick>(IndicatorInput(ticks)),
    'open': (List<Tick> ticks) =>
        OpenValueIndicator<Tick>(IndicatorInput(ticks)),
    'Hl/2': (List<Tick> ticks) => HL2Indicator<Tick>(IndicatorInput(ticks)),
    // TODO(Ramin): Add also hlc3, hlcc4, ohlc4 Indicators.
  };

  Series getSeries(List<Tick> ticks);
}
