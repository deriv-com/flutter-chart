import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';

import 'callbacks.dart';

/// Indicator config
abstract class IndicatorConfig {
  /// Initializes
  const IndicatorConfig();

  /// Indicators supported field types
  static final Map<String, FieldIndicatorBuilder> supportedFieldTypes =
      <String, FieldIndicatorBuilder>{
    'close': (IndicatorInput indicatorInput) =>
        CloseValueIndicator<Tick>(indicatorInput),
    'high': (IndicatorInput indicatorInput) =>
        HighValueIndicator<Tick>(indicatorInput),
    'low': (IndicatorInput indicatorInput) =>
        LowValueIndicator<Tick>(indicatorInput),
    'open': (IndicatorInput indicatorInput) =>
        OpenValueIndicator<Tick>(indicatorInput),
    'Hl/2': (IndicatorInput indicatorInput) =>
        HL2Indicator<Tick>(indicatorInput),
    'HlC/3': (IndicatorInput indicatorInput) =>
        HLC3Indicator<Tick>(indicatorInput),
    'HlCC/4': (IndicatorInput indicatorInput) =>
        HLCC4Indicator<Tick>(indicatorInput),
    'OHlC/4': (IndicatorInput indicatorInput) =>
        OHLC4Indicator<Tick>(indicatorInput),
  };

  /// Creates indicator [Series] for the given [indicatorInput].
  Series getSeries(IndicatorInput indicatorInput);
}
