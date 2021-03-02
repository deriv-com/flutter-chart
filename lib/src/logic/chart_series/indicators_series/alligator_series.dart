import 'dart:math';

import 'package:deriv_chart/src/logic/chart_series/indicators_series/models/alligator_options.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/models/indicator_options.dart';
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
import 'ma_series.dart';


/// A series which shows Moving Average Envelope data calculated from 'entries'.
class AlligatorSeries extends Series {
  /// Initializes a series which shows shows moving Average data calculated from [entries].
  ///
  /// [maEnvOptions] Moving Average Envelope indicator options.
  AlligatorSeries(
    IndicatorInput indicatorInput, {
    String id,
    AlligatorOptions alligatorOptions,
  }) : this.fromIndicator(
          CloseValueIndicator<Tick>(indicatorInput),
          id: id,
          alligatorOptions: alligatorOptions,
        );

  /// Initializes
  AlligatorSeries.fromIndicator(
    Indicator<Tick> indicator, {
    String id,
    this.alligatorOptions,
  })  : _fieldIndicator = indicator,
        super(id);

  final Indicator<Tick> _fieldIndicator;

  /// Moving Average Envelope options
  AlligatorOptions alligatorOptions;

  SingleIndicatorSeries _jawSeries;
  SingleIndicatorSeries _teethSeries;
  SingleIndicatorSeries _lipsSeries;

  @override
  SeriesPainter<Series> createPainter() {
    _jawSeries = SingleIndicatorSeries(
      painterCreator: (
        Series series,
      ) =>
          LinePainter(series),
      indicatorCreator: () => SMMAIndicator(
          _fieldIndicator, alligatorOptions.jawPeriod,alligatorOptions.jawOffset.toDouble()),
      inputIndicator: _fieldIndicator,
      options: alligatorOptions,
      style: const LineStyle(color: Colors.blue),
      offset: alligatorOptions.jawOffset,
    );

    _teethSeries = SingleIndicatorSeries(
      painterCreator: (
        Series series,
      ) =>
          LinePainter(series),
      indicatorCreator: () => SMMAIndicator(
          _fieldIndicator, alligatorOptions.teethPeriod,alligatorOptions.teethOffset.toDouble()),
      inputIndicator: _fieldIndicator,
      options: alligatorOptions,
      style: const LineStyle(color: Colors.red),
      offset: alligatorOptions.teethOffset,
    );

    _lipsSeries = SingleIndicatorSeries(
      painterCreator: (
        Series series,
      ) =>
          LinePainter(series),
      indicatorCreator: () => SMMAIndicator(
          _fieldIndicator, alligatorOptions.lipsPeriod,alligatorOptions.lipsOffset.toDouble()),
      inputIndicator: _fieldIndicator,
      options: alligatorOptions,
      style: const LineStyle(color: Colors.green),
      offset: alligatorOptions.lipsOffset,
    );

    return null;
  }

  @override
  bool didUpdate(ChartData oldData) {
    final AlligatorSeries series = oldData;

    final bool _lowerUpdated = _jawSeries.didUpdate(series?._jawSeries);
    final bool _middleUpdated = _teethSeries.didUpdate(series?._teethSeries);
    final bool _upperUpdated = _lipsSeries.didUpdate(series?._lipsSeries);

    return _lowerUpdated || _middleUpdated || _upperUpdated;
  }

  @override
  void onUpdate(int leftEpoch, int rightEpoch) {
    _jawSeries.update(leftEpoch, rightEpoch);
    _teethSeries.update(leftEpoch, rightEpoch);
    _lipsSeries.update(leftEpoch, rightEpoch);
  }

  @override
  List<double> recalculateMinMax() =>
      // Can just use _lowerSeries minValue for min and _upperSeries maxValue for max.
      // But to be safe we calculate min and max. from all three series.
      <double>[
        min(
          min(_jawSeries.minValue, _teethSeries.minValue),
          _lipsSeries.minValue,
        ),
        max(
          max(_jawSeries.maxValue, _teethSeries.maxValue),
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
  int getMaxEpoch() => max(
        max(_jawSeries?.getMaxEpoch(), _teethSeries?.getMaxEpoch()),
        _lipsSeries.getMaxEpoch(),
      );

  @override
  int getMinEpoch() => min(
        min(_jawSeries?.getMinEpoch(), _teethSeries?.getMinEpoch()),
        _lipsSeries?.getMinEpoch(),
      );
}
