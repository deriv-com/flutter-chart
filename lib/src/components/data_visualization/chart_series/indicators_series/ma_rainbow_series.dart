import 'dart:math';

import 'package:deriv_chart/src/components/data_visualization/chart_series/indicators_series/ma_series.dart';
import 'package:deriv_chart/src/components/data_visualization/chart_series/indicators_series/single_indicator_series.dart';
import 'package:deriv_chart/src/components/data_visualization/chart_series/line_series/line_painter.dart';
import 'package:deriv_chart/src/components/data_visualization/chart_series/series.dart';
import 'package:deriv_chart/src/components/data_visualization/chart_series/series_painter.dart';
import 'package:deriv_chart/src/logic/chart_data.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';
import 'package:flutter/material.dart';

import 'models/rainbow_options.dart';

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

  /// colors of rainbow bands
  final List<Color> rainbowColors;

  @override
  SeriesPainter<Series> createPainter() {
    /// check if we have color for every band
    final bool useColors = rainbowColors?.length == rainbowOptions.bandsCount;
    final List<Indicator<Tick>> indicators = <Indicator<Tick>>[];
    for (int i = 0; i < rainbowOptions.bandsCount; i++) {
      if (i == 0) {
        indicators
            .add(MASeries.getMAIndicator(_fieldIndicator, rainbowOptions));
        _rainbowSeries.add(SingleIndicatorSeries(
          painterCreator: (
            Series series,
          ) =>
              LinePainter(series),
          indicatorCreator: () => indicators[0],
          inputIndicator: _fieldIndicator,
          options: rainbowOptions,
          style: LineStyle(color: useColors ? rainbowColors[i] : Colors.red),
        ));
      } else {
        indicators
            .add(MASeries.getMAIndicator(indicators[i - 1], rainbowOptions));
        _rainbowSeries.add(SingleIndicatorSeries(
          painterCreator: (
            Series series,
          ) =>
              LinePainter(series),
          indicatorCreator: () => indicators[i],
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
    } else if (oldRainbowSeries._rainbowSeries.length !=
        _rainbowSeries.length) {
      return true;
    }

    bool needUpdate = false;
    for (int i = 0; i < _rainbowSeries.length; i++) {
      if (_rainbowSeries[i].didUpdate(oldRainbowSeries._rainbowSeries[i])) {
        needUpdate = true;
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
        _getMinValue(),
        _getMaxValue(),
      ];

  /// Returns minimum value of all series
  double _getMinValue() {
    final List<double> minValues = <double>[];
    for (final SingleIndicatorSeries series in _rainbowSeries) {
      minValues.add(series.minValue);
    }
    return minValues.reduce(min);
  }

  /// Returns maximum value of all series
  double _getMaxValue() {
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

  @override
  int getMaxEpoch() =>
      _rainbowSeries.isNotEmpty ? _rainbowSeries[0].getMaxEpoch() : null;

  @override
  int getMinEpoch() =>
      _rainbowSeries.isNotEmpty ? _rainbowSeries[0].getMinEpoch() : null;
}
