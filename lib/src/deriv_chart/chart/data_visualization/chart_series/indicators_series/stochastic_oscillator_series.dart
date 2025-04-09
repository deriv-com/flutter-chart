import 'package:deriv_chart/src/add_ons/indicators_ui/stochastic_oscillator_indicator/stochastic_oscillator_indicator_config.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/data_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/models/stochastic_oscillator_options.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/single_indicator_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/line_series/line_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/line_series/oscillator_line_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/chart_scale_model.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/indicator.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';
import 'package:flutter/material.dart';

/// A series which shows Stochastic Oscillator Series data calculated
/// from 'entries'.
class StochasticOscillatorSeries extends Series {
  /// Initializes a series which shows shows Stochastic Oscillator data
  /// calculated from [inputIndicator].
  StochasticOscillatorSeries(
    this.inputIndicator,
    this.config, {
    required this.stochasticOscillatorOptions,
    String? id,
  }) : super(id ?? 'StochasticOscillator');

  /// Fast percent StochasticOscillator indicator series.
  late SingleIndicatorSeries fastPercentStochasticIndicatorSeries;

  /// Slow percent StochasticOscillator indicator series.
  late SingleIndicatorSeries slowStochasticIndicatorSeries;

  ///input data
  final Indicator<Tick> inputIndicator;

  /// Configuration of StochasticOscillator.
  final StochasticOscillatorIndicatorConfig config;

  /// Options for StochasticOscillator Indicator.
  final StochasticOscillatorOptions stochasticOscillatorOptions;

  @override
  SeriesPainter<Series>? createPainter() {
    final FastStochasticIndicator<Tick> fastStochasticIndicator =
        FastStochasticIndicator<Tick>.fromIndicator(inputIndicator,
            period: stochasticOscillatorOptions.period);

    final SlowStochasticIndicator<Tick> slowStochasticIndicator =
        SlowStochasticIndicator<Tick>.fromIndicator(fastStochasticIndicator);

    if (config.isSmooth) {
      final SmoothedFastStochasticIndicator<Tick>
          smoothedFastStochasticIndicator =
          SmoothedFastStochasticIndicator<Tick>(fastStochasticIndicator,
              period: stochasticOscillatorOptions.period);

      fastPercentStochasticIndicatorSeries = SingleIndicatorSeries(
        painterCreator: (Series series) => config.showZones
            ? OscillatorLinePainter(
                series as DataSeries<Tick>,
                bottomHorizontalLine: config.overSoldPrice,
                topHorizontalLine: config.overBoughtPrice,
                topHorizontalLinesStyle:
                    config.oscillatorLinesConfig.overboughtStyle,
                bottomHorizontalLinesStyle:
                    config.oscillatorLinesConfig.oversoldStyle,
              )
            : LinePainter(series as DataSeries<Tick>),
        indicatorCreator: () => smoothedFastStochasticIndicator,
        inputIndicator: inputIndicator,
        options: stochasticOscillatorOptions,
        style: config.fastLineStyle,
        lastTickIndicatorStyle: getLastIndicatorStyle(
          config.fastLineStyle.color,
          showLastIndicator: config.showLastIndicator,
        ),
      );

      slowStochasticIndicatorSeries = SingleIndicatorSeries(
        painterCreator: (Series series) =>
            LinePainter(series as DataSeries<Tick>),
        indicatorCreator: () =>
            SmoothedSlowStochasticIndicator<Tick>(slowStochasticIndicator),
        inputIndicator: inputIndicator,
        options: stochasticOscillatorOptions,
        style: config.slowLineStyle,
        lastTickIndicatorStyle: getLastIndicatorStyle(
          config.slowLineStyle.color,
          showLastIndicator: config.showLastIndicator,
        ),
      );
    } else {
      fastPercentStochasticIndicatorSeries = SingleIndicatorSeries(
        painterCreator: (Series series) => config.showZones
            ? OscillatorLinePainter(
                series as DataSeries<Tick>,
                bottomHorizontalLine: config.overSoldPrice,
                topHorizontalLine: config.overBoughtPrice,
                topHorizontalLinesStyle:
                    config.oscillatorLinesConfig.overboughtStyle,
                bottomHorizontalLinesStyle:
                    config.oscillatorLinesConfig.oversoldStyle,
              )
            : LinePainter(series as DataSeries<Tick>),
        indicatorCreator: () => fastStochasticIndicator,
        options: stochasticOscillatorOptions,
        inputIndicator: inputIndicator,
        style: config.fastLineStyle,
        lastTickIndicatorStyle: getLastIndicatorStyle(
          config.fastLineStyle.color,
          showLastIndicator: config.showLastIndicator,
        ),
      );

      slowStochasticIndicatorSeries = SingleIndicatorSeries(
        painterCreator: (Series series) =>
            LinePainter(series as DataSeries<Tick>),
        indicatorCreator: () => slowStochasticIndicator,
        inputIndicator: inputIndicator,
        options: stochasticOscillatorOptions,
        style: config.slowLineStyle,
        lastTickIndicatorStyle: getLastIndicatorStyle(
          config.slowLineStyle.color,
          showLastIndicator: config.showLastIndicator,
        ),
      );
    }
    return null;
  }

  @override
  bool didUpdate(ChartData? oldData) {
    final StochasticOscillatorSeries? series =
        oldData as StochasticOscillatorSeries?;
    final bool _fastUpdated = fastPercentStochasticIndicatorSeries
        .didUpdate(series?.fastPercentStochasticIndicatorSeries);
    final bool _slowUpdated = slowStochasticIndicatorSeries
        .didUpdate(series?.slowStochasticIndicatorSeries);

    return _fastUpdated || _slowUpdated;
  }

  @override
  void onUpdate(int leftEpoch, int rightEpoch) {
    fastPercentStochasticIndicatorSeries.update(leftEpoch, rightEpoch);
    slowStochasticIndicatorSeries.update(leftEpoch, rightEpoch);
  }

  @override
  List<double> recalculateMinMax() => <double>[
        <ChartData>[
          fastPercentStochasticIndicatorSeries,
          slowStochasticIndicatorSeries,
        ].getMinValue(),
        <ChartData>[
          fastPercentStochasticIndicatorSeries,
          slowStochasticIndicatorSeries,
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
    ChartScaleModel chartScaleModel,
  ) {
    fastPercentStochasticIndicatorSeries.paint(canvas, size, epochToX, quoteToY,
        animationInfo, chartConfig, theme, chartScaleModel);
    slowStochasticIndicatorSeries.paint(canvas, size, epochToX, quoteToY,
        animationInfo, chartConfig, theme, chartScaleModel);
  }

  @override
  int? getMaxEpoch() => <ChartData>[
        fastPercentStochasticIndicatorSeries,
        slowStochasticIndicatorSeries,
      ].getMaxEpoch();

  @override
  int? getMinEpoch() => <ChartData>[
        fastPercentStochasticIndicatorSeries,
        slowStochasticIndicatorSeries,
      ].getMinEpoch();
}
