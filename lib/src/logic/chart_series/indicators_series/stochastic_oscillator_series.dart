import 'package:deriv_chart/src/deriv_chart/indicators_ui/stochastic_oscillator_indicator/stochastic_oscillator_indicator_config.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/models/stochastic_oscillator_options.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/single_indicator_series.dart';
import 'package:deriv_chart/src/logic/chart_series/line_series/line_painter.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';
import 'package:flutter/material.dart';

import '../../chart_data.dart';
import '../series.dart';
import '../series_painter.dart';;

/// A series which shows Stochastic Oscillator Series data calculated from 'entries'.
class StochasticOscillatorSeries extends Series {
  /// Initializes a series which shows shows Stochastic Oscillator data calculated from [indicatorInput].
  StochasticOscillatorSeries(
    this.indicatorInput,
    this.config, {
    String id,
    this.stochasticOscillatorOptions,
  }) : super(id);

  SingleIndicatorSeries _fastStochasticIndicatorSeries;
  SingleIndicatorSeries _slowStochasticIndicatorSeries;

  ///input data
  final Indicator<Tick> indicatorInput;

  /// Configuration of StochasticOscillator.
  final StochasticOscillatorIndicatorConfig config;

  /// Options for StochasticOscillator Indicator.
  final StochasticOscillatorOptions stochasticOscillatorOptions;

  @override
  SeriesPainter<Series> createPainter() {
    final FastStochasticIndicator<Tick> fastStochasticIndicator =
        FastStochasticIndicator<Tick>.(indicatorInput,
            period: stochasticOscillatorOptions.period);
    _fastStochasticIndicatorSeries = SingleIndicatorSeries(
      painterCreator: (Series series) => LinePainter(series),
      indicatorCreator: () => fastStochasticIndicator,
      inputIndicator: CloseValueIndicator<Tick>(indicatorInput),
      style: const LineStyle(color: Colors.white),
    );

    _slowStochasticIndicatorSeries = SingleIndicatorSeries(
      painterCreator: (Series series) => LinePainter(series),
      indicatorCreator: () => SlowStochasticIndicator<Tick>(indicatorInput,
          stochasticIndicator: fastStochasticIndicator),
      inputIndicator: CloseValueIndicator<Tick>(indicatorInput),
      style: const LineStyle(color: Colors.red),
    );

    return null;
  }

  @override
  bool didUpdate(ChartData oldData) {
    final StochasticOscillatorSeries series = oldData;
    final bool _fcbHighUpdated = _fastStochasticIndicatorSeries
        .didUpdate(series?._fastStochasticIndicatorSeries);
    final bool _fcbLowUpdated = _slowStochasticIndicatorSeries
        .didUpdate(series?._slowStochasticIndicatorSeries);
    return _fcbHighUpdated || _fcbLowUpdated;
  }

  @override
  void onUpdate(int leftEpoch, int rightEpoch) {
    _fastStochasticIndicatorSeries.update(leftEpoch, rightEpoch);
    _slowStochasticIndicatorSeries.update(leftEpoch, rightEpoch);
  }

  @override
  List<double> recalculateMinMax() => <double>[
        <ChartData>[
          _fastStochasticIndicatorSeries,
          _slowStochasticIndicatorSeries,
        ].getMinValue(),
        <ChartData>[
          _fastStochasticIndicatorSeries,
          _slowStochasticIndicatorSeries,
        ].getMaxValue()
      ];

  @override
  void paint(
    Canvas canvas,
    Size size,
    double Function(int) epochToX,
    double Function(double) quoteToY,
    AnimationInfo animationInfo,
    ChartConfig chartConfig,
    ChartTheme theme,
  ) {
    _fastStochasticIndicatorSeries.paint(
        canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);
    _slowStochasticIndicatorSeries.paint(
        canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);
  }

  @override
  int getMaxEpoch() => <ChartData>[
        _fastStochasticIndicatorSeries,
        _slowStochasticIndicatorSeries,
      ].getMaxEpoch();

  @override
  int getMinEpoch() => <ChartData>[
        _fastStochasticIndicatorSeries,
        _slowStochasticIndicatorSeries,
      ].getMinEpoch();
}
