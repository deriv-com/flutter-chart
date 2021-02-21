import 'dart:math';

import 'package:deriv_chart/src/logic/chart_data.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/models/rainbow_options.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/single_indicator_series.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/ma_series.dart';
import 'package:deriv_chart/src/logic/chart_series/line_series/line_painter.dart';
import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/logic/chart_series/series_painter.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';
import 'package:flutter/material.dart';

import '../../../../deriv_chart.dart';

/// Rainbow series
class RainbowSeries extends Series {
  /// Initializes a series which shows shows Rainbow Series data calculated from [entries].
  ///
  /// [rainbowOptions] Rainbow indicator options.
  RainbowSeries(
    IndicatorInput indicatorInput, {
    List<Color> rainbowColors,
    String id,
    RainbowOptions rainbowOptions,
  }) : this.fromIndicator(
          CloseValueIndicator<Tick>(indicatorInput),
          rainbowColors: rainbowColors,
          id: id,
          rainbowOptions: rainbowOptions,
        );

  /// Initializes
  RainbowSeries.fromIndicator(
    Indicator<Tick> indicator, {
    this.rainbowColors,
    String id,
    this.rainbowOptions,
  })  : _fieldIndicator = indicator,
        super(id);

  final Indicator<Tick> _fieldIndicator;

  /// Rainbow options
  RainbowOptions rainbowOptions;

  final List<SingleIndicatorSeries> _rainbowSeries = <SingleIndicatorSeries>[];

  ///colors of rainbow bands
  List<Color> rainbowColors;

  @override
  SeriesPainter<Series> createPainter() {
    /// check if we have color for every band
    final bool useColors = rainbowColors?.length == rainbowOptions.bandsCount;

    for (int i = 0; i < rainbowOptions.bandsCount; i++) {
      if (i == 0) {
        _rainbowSeries.add(SingleIndicatorSeries(
          painterCreator: (
            Series series,
          ) =>
              LinePainter(series),
          indicatorCreator: () =>
              MASeries.getMAIndicator(_fieldIndicator, rainbowOptions),
          inputIndicator: _fieldIndicator,
          options: rainbowOptions,
          style: LineStyle(color: useColors ? rainbowColors[i] : Colors.red),
        ));
      } else {
        _rainbowSeries.add(SingleIndicatorSeries(
          painterCreator: (
            Series series,
          ) =>
              LinePainter(series),
          indicatorCreator: () => MASeries.getMAIndicator(
              _rainbowSeries[i - 1].resultIndicator, rainbowOptions),
          inputIndicator: _fieldIndicator,
          options: rainbowOptions,
          style: LineStyle(color: useColors ? rainbowColors[i] : Colors.red),
        ));
      }
    }
    return null;
  }

  @override
  bool didUpdate(ChartData oldData) {
    final RainbowSeries oldRainbowSeries = oldData;
    if (oldRainbowSeries == null) {
      return false;
    }
    bool needUpdate = false;
    if (oldRainbowSeries._rainbowSeries.length == _rainbowSeries.length) {
      for (int i = 0; i < _rainbowSeries.length; i++) {
        if (_rainbowSeries[i].didUpdate(oldRainbowSeries._rainbowSeries[i])) {
          needUpdate = true;
        }
      }
    }
    return needUpdate;
  }

  @override
  void onUpdate(int leftEpoch, int rightEpoch) {
    for (final SingleIndicatorSeries series in _rainbowSeries) {
      series.update(leftEpoch, rightEpoch);
    }
  }

  @override
  List<double> recalculateMinMax() =>
      // To be safe we calculate min and max. from all series inside rainbow.
      <double>[
        getMinValue(),
        getMaxValue(),
      ];

  /// Returns minimum value of all series
  double getMinValue() {
    final List<double> minValues = <double>[];
    for (final SingleIndicatorSeries series in _rainbowSeries) {
      minValues.add(series.minValue);
    }
    return minValues.reduce(min);
  }

  /// Returns maximum value of all series
  double getMaxValue() {
    final List<double> maxValues = <double>[];
    for (final SingleIndicatorSeries series in _rainbowSeries) {
      maxValues.add(series.maxValue);
    }
    return maxValues.reduce(max);
  }

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
    for (final SingleIndicatorSeries series in _rainbowSeries) {
      series.paint(
        canvas,
        size,
        epochToX,
        quoteToY,
        animationInfo,
        chartConfig,
        theme,
      );
    }
  }
}
