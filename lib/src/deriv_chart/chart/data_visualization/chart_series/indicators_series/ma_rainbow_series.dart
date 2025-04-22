import 'dart:math';

import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/line_series/line_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/chart_scale_model.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/indicator.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';
import 'package:flutter/material.dart';

import '../../chart_data.dart';
import '../data_series.dart';
import '../series.dart';
import '../series_painter.dart';
import 'ma_series.dart';
import 'models/rainbow_options.dart';
import 'single_indicator_series.dart';

/// Rainbow series
class RainbowSeries extends Series {
  /// Initializes a series which shows shows Rainbow Series data calculated
  /// from `entries`.
  ///
  /// [rainbowOptions] Rainbow indicator options.
  RainbowSeries(
    IndicatorInput indicatorInput, {
    required RainbowOptions rainbowOptions,
    List<LineStyle>? rainbowLineStyles,
    String? id,
  }) : this.fromIndicator(
          CloseValueIndicator<Tick>(indicatorInput),
          rainbowLineStyles: rainbowLineStyles ?? const <LineStyle>[],
          id: id,
          rainbowOptions: rainbowOptions,
        );

  /// Initializes
  RainbowSeries.fromIndicator(
    Indicator<Tick> indicator, {
    required this.rainbowOptions,
    this.rainbowLineStyles = const <LineStyle>[],
    String? id,
  })  : _fieldIndicator = indicator,
        super(id ?? 'MARainbow$rainbowOptions');

  final Indicator<Tick> _fieldIndicator;

  /// Rainbow options
  RainbowOptions rainbowOptions;

  /// Rainbow series
  final List<SingleIndicatorSeries> rainbowSeries = <SingleIndicatorSeries>[];

  /// Line styles of rainbow bands
  final List<LineStyle> rainbowLineStyles;

  @override
  SeriesPainter<Series>? createPainter() {
    /// check if we have color for every band
    final bool useColors =
        rainbowLineStyles.length == rainbowOptions.bandsCount;
    final List<Indicator<Tick>> indicators = <Indicator<Tick>>[];
    for (int i = 0; i < rainbowOptions.bandsCount; i++) {
      final LineStyle style =
          useColors ? rainbowLineStyles[i] : const LineStyle(color: Colors.red);
      if (i == 0) {
        indicators
            .add(MASeries.getMAIndicator(_fieldIndicator, rainbowOptions));
        rainbowSeries.add(SingleIndicatorSeries(
          painterCreator: (Series series) =>
              LinePainter(series as DataSeries<Tick>),
          indicatorCreator: () => indicators[0] as CachedIndicator<Tick>,
          inputIndicator: _fieldIndicator,
          options: rainbowOptions,
          style: style,
          lastTickIndicatorStyle: getLastIndicatorStyle(
            style.color,
            showLastIndicator: rainbowOptions.showLastIndicator,
          ),
        ));
      } else {
        indicators
            .add(MASeries.getMAIndicator(indicators[i - 1], rainbowOptions));
        rainbowSeries.add(SingleIndicatorSeries(
          painterCreator: (Series series) =>
              LinePainter(series as DataSeries<Tick>),
          indicatorCreator: () => indicators[i] as CachedIndicator<Tick>,
          inputIndicator: _fieldIndicator,
          options: rainbowOptions,
          style: style,
          lastTickIndicatorStyle: getLastIndicatorStyle(
            style.color,
            showLastIndicator: rainbowOptions.showLastIndicator,
          ),
        ));
      }
    }
    return null;
  }

  @override
  bool didUpdate(ChartData? oldData) {
    final RainbowSeries? oldRainbowSeries = oldData as RainbowSeries?;
    if (oldRainbowSeries == null) {
      return false;
    } else if (oldRainbowSeries.rainbowSeries.length != rainbowSeries.length) {
      return true;
    }

    bool needUpdate = false;
    for (int i = 0; i < rainbowSeries.length; i++) {
      if (rainbowSeries[i].didUpdate(oldRainbowSeries.rainbowSeries[i])) {
        needUpdate = true;
      }
    }
    return needUpdate;
  }

  @override
  void onUpdate(int leftEpoch, int rightEpoch) {
    for (final SingleIndicatorSeries series in rainbowSeries) {
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
    for (final SingleIndicatorSeries series in rainbowSeries) {
      minValues.add(series.minValue);
    }
    return minValues.reduce(min);
  }

  /// Returns maximum value of all series
  double _getMaxValue() {
    final List<double> maxValues = <double>[];
    for (final SingleIndicatorSeries series in rainbowSeries) {
      maxValues.add(series.maxValue);
    }
    return maxValues.reduce(max);
  }

  @override
  bool shouldRepaint(ChartData? previous) {
    if (previous == null) {
      return true;
    }

    final RainbowSeries oldSeries = previous as RainbowSeries;
    return rainbowOptions != oldSeries.rainbowOptions ||
        rainbowLineStyles != oldSeries.rainbowLineStyles;
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
    ChartScaleModel chartScaleModel,
  ) {
    for (final SingleIndicatorSeries series in rainbowSeries) {
      series.paint(
        canvas,
        size,
        epochToX,
        quoteToY,
        animationInfo,
        chartConfig,
        theme,
        chartScaleModel,
      );
    }
  }

  @override
  int? getMaxEpoch() =>
      rainbowSeries.isNotEmpty ? rainbowSeries[0].getMaxEpoch() : null;

  @override
  int? getMinEpoch() =>
      rainbowSeries.isNotEmpty ? rainbowSeries[0].getMinEpoch() : null;
}
