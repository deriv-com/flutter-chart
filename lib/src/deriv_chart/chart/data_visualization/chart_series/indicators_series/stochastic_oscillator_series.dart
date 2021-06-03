import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/models/stochastic_oscillator_options.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/single_indicator_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/line_series/line_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/line_series/oscillator_line_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/deriv_chart/indicators_ui/stochastic_oscillator_indicator/stochastic_oscillator_indicator_config.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';
import 'package:flutter/material.dart';



/// A series which shows Stochastic Oscillator Series data calculated from 'entries'.
class StochasticOscillatorSeries extends Series {
  /// Initializes a series which shows shows Stochastic Oscillator data calculated from [inputIndicator].
  StochasticOscillatorSeries(
    this.inputIndicator,
    this.config, {
    String id,
    this.stochasticOscillatorOptions,
  }) : super(id);

  SingleIndicatorSeries _smoothedFastPercentStochasticIndicatorSeries;
  SingleIndicatorSeries _fastPercentStochasticIndicatorSeries;
  SingleIndicatorSeries _slowStochasticIndicatorSeries;
  SingleIndicatorSeries _smoothedSlowStochasticIndicatorSeries;

  ///input data
  final Indicator<Tick> inputIndicator;

  /// Configuration of StochasticOscillator.
  final StochasticOscillatorIndicatorConfig config;

  /// Options for StochasticOscillator Indicator.
  final StochasticOscillatorOptions stochasticOscillatorOptions;

  @override
  SeriesPainter<Series> createPainter() {
    final FastStochasticIndicator<Tick> fastStochasticIndicator =
        FastStochasticIndicator<Tick>.fromIndicator(inputIndicator,
            period: stochasticOscillatorOptions.period);

    final SlowStochasticIndicator<Tick> slowStochasticIndicator =
        SlowStochasticIndicator.fromIndicator(fastStochasticIndicator);
    _fastPercentStochasticIndicatorSeries = SingleIndicatorSeries(
      painterCreator: (Series series) => config.showZones
          ? OscillatorLinePainter(
              series,
              bottomHorizontalLine: config.overSoldPrice,
              topHorizontalLine: config.overBoughtPrice,
              mainHorizontalLinesStyle: config.mainHorizontalLinesStyle,
            )
          : LinePainter(series),
      indicatorCreator: () => fastStochasticIndicator,
      inputIndicator: inputIndicator,
      style: const LineStyle(color: Colors.white),
    );

    _slowStochasticIndicatorSeries = SingleIndicatorSeries(
      painterCreator: (Series series) => config.showZones
          ? OscillatorLinePainter(
              series,
              bottomHorizontalLine: config.overSoldPrice,
              topHorizontalLine: config.overBoughtPrice,
              mainHorizontalLinesStyle: config.mainHorizontalLinesStyle,
            )
          : LinePainter(series),
      indicatorCreator: () => slowStochasticIndicator,
      inputIndicator: inputIndicator,
      style: const LineStyle(color: Colors.red),
    );

    if (config.isSmooth) {
      final SmoothedFastStochasticIndicator<Tick>
          smoothedFastStochasticIndicator =
          SmoothedFastStochasticIndicator<Tick>(fastStochasticIndicator,
              period: stochasticOscillatorOptions.period);

      _smoothedFastPercentStochasticIndicatorSeries = SingleIndicatorSeries(
        painterCreator: (Series series) => config.showZones
            ? OscillatorLinePainter(
                series,
                bottomHorizontalLine: config.overSoldPrice,
                topHorizontalLine: config.overBoughtPrice,
                mainHorizontalLinesStyle: config.mainHorizontalLinesStyle,
              )
            : LinePainter(series),
        indicatorCreator: () => smoothedFastStochasticIndicator,
        inputIndicator: inputIndicator,
        style: const LineStyle(color: Colors.white),
      );

      _smoothedSlowStochasticIndicatorSeries = SingleIndicatorSeries(
        painterCreator: (Series series) => config.showZones
            ? OscillatorLinePainter(
                series,
                bottomHorizontalLine: config.overSoldPrice,
                topHorizontalLine: config.overBoughtPrice,
                mainHorizontalLinesStyle: config.mainHorizontalLinesStyle,
              )
            : LinePainter(series),
        indicatorCreator: () =>
            SmoothedSlowStochasticIndicator<Tick>(slowStochasticIndicator),
        inputIndicator: inputIndicator,
        style: const LineStyle(color: Colors.red),
      );
    }
    return null;
  }

  @override
  bool didUpdate(ChartData oldData) {
    final StochasticOscillatorSeries series = oldData;

    final bool _fastUpdated = _fastPercentStochasticIndicatorSeries
        .didUpdate(series?._fastPercentStochasticIndicatorSeries);
    final bool _slowUpdated = _slowStochasticIndicatorSeries
        .didUpdate(series?._slowStochasticIndicatorSeries);

    if (config.isSmooth) {
      final bool _smoothedFastUpdated =
          _smoothedFastPercentStochasticIndicatorSeries
              .didUpdate(series?._smoothedFastPercentStochasticIndicatorSeries);
      final bool _smoothedSlowUpdated = _smoothedSlowStochasticIndicatorSeries
          .didUpdate(series?._smoothedSlowStochasticIndicatorSeries);

      return _fastUpdated ||
          _slowUpdated ||
          _smoothedFastUpdated | _smoothedSlowUpdated;
    }

    return _fastUpdated || _slowUpdated;
  }

  @override
  void onUpdate(int leftEpoch, int rightEpoch) {
    _smoothedFastPercentStochasticIndicatorSeries?.update(
        leftEpoch, rightEpoch);
    _smoothedSlowStochasticIndicatorSeries?.update(leftEpoch, rightEpoch);
    _fastPercentStochasticIndicatorSeries.update(leftEpoch, rightEpoch);
    _slowStochasticIndicatorSeries.update(leftEpoch, rightEpoch);
  }

  @override
  List<double> recalculateMinMax() => config.isSmooth
      ? <double>[
          <ChartData>[
            _smoothedFastPercentStochasticIndicatorSeries,
            _smoothedSlowStochasticIndicatorSeries,
          ].getMinValue(),
          <ChartData>[
            _smoothedFastPercentStochasticIndicatorSeries,
            _smoothedSlowStochasticIndicatorSeries,
          ].getMaxValue()
        ]
      : <double>[
          <ChartData>[
            _fastPercentStochasticIndicatorSeries,
            _slowStochasticIndicatorSeries,
          ].getMinValue(),
          <ChartData>[
            _fastPercentStochasticIndicatorSeries,
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
    if (!config.isSmooth) {
      _fastPercentStochasticIndicatorSeries.paint(
          canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);
      _slowStochasticIndicatorSeries.paint(
          canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);
    } else {
      _smoothedFastPercentStochasticIndicatorSeries.paint(
          canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);
      _smoothedSlowStochasticIndicatorSeries.paint(
          canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);
    }
  }

  @override
  int getMaxEpoch() => <ChartData>[
        _smoothedFastPercentStochasticIndicatorSeries,
        _fastPercentStochasticIndicatorSeries,
        _slowStochasticIndicatorSeries,
      ].getMaxEpoch();

  @override
  int getMinEpoch() => <ChartData>[
        _smoothedFastPercentStochasticIndicatorSeries,
        _fastPercentStochasticIndicatorSeries,
        _slowStochasticIndicatorSeries,
      ].getMinEpoch();
}
