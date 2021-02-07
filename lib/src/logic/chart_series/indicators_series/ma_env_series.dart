import 'dart:math';

import 'package:deriv_chart/src/logic/chart_series/indicators_series/models/indicator_options.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/single_indicator_series.dart';
import 'package:deriv_chart/src/logic/chart_series/line_series/line_painter.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/ma_env/ma_env_lower_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/ma_env/ma_env_upper_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/indicator.dart';
import 'package:deriv_chart/src/logic/indicators/cached_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/helper_indicators/close_value_inidicator.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/ma_env/ma_env_shift_typs.dart';
import 'package:flutter/material.dart';

import '../../../../deriv_chart.dart';
import '../../chart_data.dart';
import '../line_series/line_series.dart';
import '../series_painter.dart';

/// A series which shows Moving Average Envelope data calculated from [entries].
class MAEnvSeries extends Series {
  /// Initializes a series which shows shows moving Average data calculated from [entries].
  ///
  /// [shiftType] The type of shifting method.
  MAEnvSeries(
    List<Tick> entries, {
    String id,
    double shift = 5,
    ShiftType shiftType = ShiftType.percent,
    MAOptions movingAverageOption,
  }) : this.fromIndicator(
          CloseValueIndicator(entries),
          id: id,
          movingAverageOption: movingAverageOption,
          shift: shift,
          shiftType: shiftType,
        );

  /// Initializes
  MAEnvSeries.fromIndicator(
    Indicator indicator, {
    String id,
    this.period = 50,
    this.movingAverageOption,
    this.shift = 5,
    this.shiftType = ShiftType.percent,
  })  : _fieldIndicator = indicator,
        super(id);

  /// Moving Average Envelope period
  final int period;

  /// Moving Average Envelope shift
  final double shift;

  /// Moving Average Envelope shiftType could be Percent or Point
  final ShiftType shiftType;

  /// Moving Average options
  final MAOptions movingAverageOption;

  final Indicator _fieldIndicator;

  SingleIndicatorSeries _lowerSeries;
  SingleIndicatorSeries _middleSeries;
  SingleIndicatorSeries _upperSeries;

  @override
  SeriesPainter<Series> createPainter() {
    final CachedIndicator smaIndicator =
        MASeries.getMAIndicator(_fieldIndicator, movingAverageOption);

    _lowerSeries = SingleIndicatorSeries(
        painterCreator: (Series series) => LinePainter(series),
        indicatorCreator: () => MAEnvLowerIndicator(
              smaIndicator,
              shiftType,
              shift,
            ),
        inputIndicator: _fieldIndicator,
        options: movingAverageOption);

    _middleSeries = SingleIndicatorSeries(
        painterCreator: (Series series) => LinePainter(series),
        indicatorCreator: () => smaIndicator,
        inputIndicator: _fieldIndicator,
        options: movingAverageOption);

    _upperSeries = SingleIndicatorSeries(
        painterCreator: (Series series) => LinePainter(series),
        indicatorCreator: () => MAEnvUpperIndicator(
              smaIndicator,
              shiftType,
              shift,
            ),
        inputIndicator: _fieldIndicator,
        options: movingAverageOption);
  }

  @override
  bool didUpdate(ChartData oldData) {
    final MAEnvSeries series = oldData;

    final bool _lowerUpdated = _lowerSeries.didUpdate(series?._lowerSeries);
    final bool _middleUpdated = _middleSeries.didUpdate(series?._middleSeries);
    final bool _upperUpdated = _upperSeries.didUpdate(series?._upperSeries);

    return _lowerUpdated || _middleUpdated || _upperUpdated;
  }

  @override
  void onUpdate(int leftEpoch, int rightEpoch) {
    _lowerSeries.update(leftEpoch, rightEpoch);
    _middleSeries.update(leftEpoch, rightEpoch);
    _upperSeries.update(leftEpoch, rightEpoch);
  }

  @override
  List<double> recalculateMinMax() =>
      // Can just use _lowerSeries minValue for min and _upperSeries maxValue for max.
      // But to be safe we calculate min and max. from all three series.
      <double>[
        min(
          min(_lowerSeries.minValue, _middleSeries.minValue),
          _upperSeries.minValue,
        ),
        max(
          max(_lowerSeries.maxValue, _middleSeries.maxValue),
          _upperSeries.maxValue,
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
    _lowerSeries.paint(
        canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);
    _middleSeries.paint(
        canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);
    _upperSeries.paint(
        canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);
  }
}
