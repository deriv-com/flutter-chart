import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/data_painters/bar_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/abstract_single_indicator_series.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/theme/painting_styles/bar_style.dart';
import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';

import '../../../../../../deriv_chart.dart';
import '../series.dart';
import '../series_painter.dart';

/// A series which shows Awesome Oscillator Series data calculated from 'entries'.
class AwesomeOscillatorSeries extends AbstractSingleIndicatorSeries {
  /// Initializes
  AwesomeOscillatorSeries(
      this._indicatorInput, {
        BarStyle barStyle = const BarStyle(),
        String? id,
      })  :
        super(
        HL2Indicator<Tick>(_indicatorInput),
        id ?? 'AwesomeOscillatorSeries',
        style: barStyle,
      );

  final IndicatorInput _indicatorInput;


  @override
  SeriesPainter<Series> createPainter() => BarPainter(
  this,
    checkColorCallback: ({
      required double previousQuote,
      required double currentQuote,
    }) =>
    currentQuote >= previousQuote,
  );

  @override
  CachedIndicator<Tick> initializeIndicator() =>
      AwesomeOscillatorIndicator<Tick>(_indicatorInput);
}
