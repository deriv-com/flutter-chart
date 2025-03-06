import 'dart:math';

import 'package:deriv_chart/src/add_ons/indicators_ui/gator/gator_indicator_config.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/data_painters/bar_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/models/alligator_options.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/chart_scale_model.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/theme/painting_styles/bar_style.dart';
import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';
import 'package:flutter/material.dart';

import '../../chart_data.dart';
import '../data_series.dart';
import '../series.dart';
import '../series_painter.dart';
import 'single_indicator_series.dart';

/// A series which shows Gator Series data calculated from 'entries'.
class GatorSeries extends Series {
  /// Initializes a series which shows shows Gator data calculated
  /// from [indicatorInput].
  ///
  /// [gatorOptions] Gator indicator options.
  GatorSeries(
    IndicatorInput indicatorInput, {
    required this.gatorOptions,
    required this.gatorConfig,
    this.barStyle = const BarStyle(),
    String? id,
  })  : _fieldIndicator = HL2Indicator<Tick>(indicatorInput),
        super(id ?? 'Gator$AlligatorOptions');

  final Indicator<Tick> _fieldIndicator;

  /// Gator options
  AlligatorOptions gatorOptions;

  /// Gator top series
  late SingleIndicatorSeries gatorTopSeries;

  /// Gator bottom series
  late SingleIndicatorSeries gatorBottomSeries;

  /// Gator config
  final GatorIndicatorConfig gatorConfig;

  /// Histogram bar style
  final BarStyle barStyle;

  @override
  SeriesPainter<Series>? createPainter() {
    gatorTopSeries = SingleIndicatorSeries(
      painterCreator: (Series series) => BarPainter(
        series as DataSeries<Tick>,
        checkColorCallback: ({
          required double previousQuote,
          required double currentQuote,
        }) =>
            currentQuote >= previousQuote,
      ),
      indicatorCreator: () => GatorOscillatorIndicatorTopBar<Tick>(
          _fieldIndicator,
          jawPeriod: gatorOptions.jawPeriod,
          jawOffset: gatorConfig.jawOffset,
          teethPeriod: gatorOptions.teethPeriod,
          teethOffset: gatorConfig.teethOffset),
      inputIndicator: _fieldIndicator,
      options: gatorOptions,
      style: barStyle,
      offset: min(gatorConfig.jawOffset, gatorConfig.teethOffset),
    );

    gatorBottomSeries = SingleIndicatorSeries(
      painterCreator: (
        Series series,
      ) =>
          BarPainter(
        series as DataSeries<Tick>,
        checkColorCallback: ({
          required double previousQuote,
          required double currentQuote,
        }) =>
            currentQuote.abs() >= previousQuote.abs(),
      ),
      indicatorCreator: () => GatorOscillatorIndicatorBottomBar<Tick>(
        _fieldIndicator,
        teethPeriod: gatorOptions.teethPeriod,
        teethOffset: gatorConfig.teethOffset,
        lipsOffset: gatorConfig.lipsOffset,
        lipsPeriod: gatorOptions.lipsPeriod,
      ),
      inputIndicator: _fieldIndicator,
      options: gatorOptions,
      style: barStyle,
      offset: min(gatorConfig.teethOffset, gatorConfig.lipsOffset),
    );

    return null;
  }

  @override
  bool didUpdate(ChartData? oldData) {
    final GatorSeries? series = oldData as GatorSeries?;
    final bool _gatorBottomUpdated =
        gatorBottomSeries.didUpdate(series?.gatorBottomSeries);
    final bool _gatorTopUpdated =
        gatorTopSeries.didUpdate(series?.gatorTopSeries);

    return _gatorTopUpdated || _gatorBottomUpdated;
  }

  @override
  void onUpdate(int leftEpoch, int rightEpoch) {
    gatorTopSeries.update(leftEpoch, rightEpoch);
    gatorBottomSeries.update(leftEpoch, rightEpoch);
  }

  @override
  List<double> recalculateMinMax() => <double>[
        <ChartData?>[gatorBottomSeries, gatorTopSeries].getMinValue(),
        <ChartData?>[gatorBottomSeries, gatorTopSeries].getMaxValue()
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
    gatorBottomSeries.paint(canvas, size, epochToX, quoteToY, animationInfo,
        chartConfig, theme, chartScaleModel);
    gatorTopSeries.paint(canvas, size, epochToX, quoteToY, animationInfo,
        chartConfig, theme, chartScaleModel);
  }

  @override
  int? getMaxEpoch() =>
      <ChartData?>[gatorBottomSeries, gatorTopSeries].getMaxEpoch();

  @override
  int? getMinEpoch() =>
      <ChartData?>[gatorBottomSeries, gatorTopSeries].getMinEpoch();
}
