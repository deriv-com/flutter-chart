// @dart=2.9

import 'dart:math';

import 'package:deriv_chart/src/helpers/helper_functions.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/models/alligator_options.dart';
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
import '../series_painter.dart';

/// A series which shows Alligator Series data calculated from 'entries'.
class AlligatorSeries extends Series {
  /// Initializes a series which shows shows Alligator data calculated from [indicatorInput].
  ///
  /// [alligatorOptions] Alligator indicator options.
  AlligatorSeries(
    IndicatorInput indicatorInput, {
    String id,
    this.alligatorOptions,
    this.jawOffset = 8,
    this.teethOffset = 5,
    this.lipsOffset = 3,
  })  : _fieldIndicator = HL2Indicator<Tick>(indicatorInput),
        super(id);

  final Indicator<Tick> _fieldIndicator;

  /// Alligator options
  AlligatorOptions alligatorOptions;

  SingleIndicatorSeries _jawSeries;
  SingleIndicatorSeries _teethSeries;
  SingleIndicatorSeries _lipsSeries;

  /// Shift to future in jaw series
  final int jawOffset;

  /// Shift to future in teeth series
  final int teethOffset;

  /// Shift to future in lips series
  final int lipsOffset;

  @override
  SeriesPainter<Series> createPainter() {
    _jawSeries = SingleIndicatorSeries(
      painterCreator: (
        Series series,
      ) =>
          LinePainter(series),
      indicatorCreator: () =>
          MMAIndicator<Tick>(_fieldIndicator, alligatorOptions.jawPeriod),
      inputIndicator: _fieldIndicator,
      options: alligatorOptions,
      style: const LineStyle(color: Colors.blue),
      offset: jawOffset,
    );

    _teethSeries = SingleIndicatorSeries(
      painterCreator: (
        Series series,
      ) =>
          LinePainter(series),
      indicatorCreator: () =>
          MMAIndicator<Tick>(_fieldIndicator, alligatorOptions.teethPeriod),
      inputIndicator: _fieldIndicator,
      options: alligatorOptions,
      style: const LineStyle(color: Colors.red),
      offset: teethOffset,
    );

    _lipsSeries = SingleIndicatorSeries(
      painterCreator: (
        Series series,
      ) =>
          LinePainter(series),
      indicatorCreator: () =>
          MMAIndicator<Tick>(_fieldIndicator, alligatorOptions.lipsPeriod),
      inputIndicator: _fieldIndicator,
      options: alligatorOptions,
      style: const LineStyle(color: Colors.green),
      offset: lipsOffset,
    );

    return null;
  }

  @override
  bool didUpdate(ChartData oldData) {
    final AlligatorSeries series = oldData;

    final bool _jawUpdated = _jawSeries.didUpdate(series?._jawSeries);
    final bool _teethUpdated = _teethSeries.didUpdate(series?._teethSeries);
    final bool _lipsUpdated = _lipsSeries.didUpdate(series?._lipsSeries);

    return _jawUpdated || _teethUpdated || _lipsUpdated;
  }

  @override
  void onUpdate(int leftEpoch, int rightEpoch) {
    _jawSeries.update(leftEpoch, rightEpoch);
    _teethSeries.update(leftEpoch, rightEpoch);
    _lipsSeries.update(leftEpoch, rightEpoch);
  }

  @override
  List<double> recalculateMinMax() => <double>[
        safeMin(
          safeMin(_jawSeries.minValue, _teethSeries.minValue),
          _lipsSeries.minValue,
        ),
        safeMax(
          safeMax(_jawSeries.maxValue, _teethSeries.maxValue),
          _lipsSeries.maxValue,
        ),
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
    _jawSeries.paint(
        canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);
    _teethSeries.paint(
        canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);
    _lipsSeries.paint(
        canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);
  }

  @override
  int getMaxEpoch() {
    final int jawSeriesMax = _jawSeries?.getMaxEpoch();
    final int teethSeriesMax = _teethSeries?.getMaxEpoch();
    final int lipsSeriesMax = _lipsSeries?.getMaxEpoch();
    return (jawSeriesMax != null &&
            teethSeriesMax != null &&
            lipsSeriesMax != null)
        ? max(jawSeriesMax, max(teethSeriesMax, lipsSeriesMax))
        : null;
  }

  @override
  int getMinEpoch() {
    final int jawSeriesMin = _jawSeries?.getMinEpoch();
    final int teethSeriesMin = _teethSeries?.getMinEpoch();
    final int lipsSeriesMin = _lipsSeries?.getMinEpoch();
    return (jawSeriesMin != null &&
            teethSeriesMin != null &&
            lipsSeriesMin != null)
        ? min(jawSeriesMin, min(teethSeriesMin, lipsSeriesMin))
        : null;
  }
}
