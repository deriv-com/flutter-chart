import 'dart:math';

import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/data_painters/bar_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/models/alligator_options.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
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
  /// Initializes a series which shows shows Gator data calculated from [indicatorInput].
  ///
  /// [gatorOptions] Gator indicator options.
  GatorSeries(
    IndicatorInput indicatorInput, {
    required this.gatorOptions,
    String? id,
    this.jawOffset = 8,
    this.teethOffset = 5,
    this.lipsOffset = 3,
  })  : _fieldIndicator = HL2Indicator<Tick>(indicatorInput),
        super(id ?? 'Gator$AlligatorOptions$jawOffset$teethOffset$lipsOffset');

  final Indicator<Tick> _fieldIndicator;

  /// Gator options
  AlligatorOptions gatorOptions;

  SingleIndicatorSeries? _gatorTopSeries;
  SingleIndicatorSeries? _gatorBottomSeries;

  /// Shift to future in jaw series
  final int jawOffset;

  /// Shift to future in teeth series
  final int teethOffset;

  /// Shift to future in lips series
  final int lipsOffset;

  @override
  SeriesPainter<Series>? createPainter() {
    _gatorTopSeries = SingleIndicatorSeries(
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
          jawOffset: jawOffset,
          teethPeriod: gatorOptions.teethPeriod,
          teethOffset: teethOffset),
      inputIndicator: _fieldIndicator,
      options: gatorOptions,
      style: const BarStyle(),
      offset: min(jawOffset, teethOffset),
    );

    _gatorBottomSeries = SingleIndicatorSeries(
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
        teethOffset: teethOffset,
        lipsOffset: lipsOffset,
        lipsPeriod: gatorOptions.lipsPeriod,
      ),
      inputIndicator: _fieldIndicator,
      options: gatorOptions,
      style: const BarStyle(),
      offset: min(teethOffset, lipsOffset),
    );

    return null;
  }

  @override
  bool didUpdate(ChartData? oldData) {
    final GatorSeries? series = oldData as GatorSeries?;
    final bool _gatorBottomUpdated =
        _gatorBottomSeries?.didUpdate(series?._gatorBottomSeries) ?? false;
    final bool _gatorTopUpdated =
        _gatorTopSeries?.didUpdate(series?._gatorTopSeries) ?? false;

    return _gatorTopUpdated || _gatorBottomUpdated;
  }

  @override
  void onUpdate(int leftEpoch, int rightEpoch) {
    _gatorTopSeries?.update(leftEpoch, rightEpoch);
    _gatorBottomSeries?.update(leftEpoch, rightEpoch);
  }

  @override
  List<double> recalculateMinMax() => <double>[
        <ChartData?>[_gatorBottomSeries, _gatorTopSeries].getMinValue(),
        <ChartData?>[_gatorBottomSeries, _gatorTopSeries].getMaxValue()
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
    _gatorBottomSeries?.paint(
        canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);
    _gatorTopSeries?.paint(
        canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);
  }

  @override
  int? getMaxEpoch() =>
      <ChartData?>[_gatorBottomSeries, _gatorTopSeries].getMaxEpoch();

  @override
  int? getMinEpoch() =>
      <ChartData?>[_gatorBottomSeries, _gatorTopSeries].getMinEpoch();
}
