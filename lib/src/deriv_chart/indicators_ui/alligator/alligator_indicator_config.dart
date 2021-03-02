import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/indicators_ui/indicator_config.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/alligator_series.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/models/alligator_options.dart';
import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';

/// Bollinger Bands Indicator Config
class AlligatorIndicatorConfig extends IndicatorConfig {
  /// Initializes
  const AlligatorIndicatorConfig({
    this.jawPeriod = 13,
    this.teethPeriod = 8,
    this.lipsPeriod = 5,
    this.jawOffset = 8,
    this.teethOffset = 5,
    this.lipsOffset = 3,
  }) : super();

  /// Number of last candles used to calculate the highest value.
  final int jawPeriod;

  /// Number of last candles used to calculate the lowest value.
  final int teethPeriod;

  /// Whether the area between upper and lower channel is filled.
  final int lipsPeriod;

  /// Upper line style.
  final int jawOffset;

  /// Middle line style.
  final int teethOffset;

  /// Lower line style.
  final int lipsOffset;


  @override
  Series getSeries(IndicatorInput indicatorInput) =>
      AlligatorSeries.fromIndicator(
        CloseValueIndicator<Tick>(indicatorInput),
        alligatorOptions: AlligatorOptions(jawOffset: jawOffset,
            teethOffset: teethOffset,
            lipsOffset: lipsOffset,
            jawPeriod: jawPeriod,
            teethPeriod: teethPeriod,
            lipsPeriod: lipsPeriod),
      );
}