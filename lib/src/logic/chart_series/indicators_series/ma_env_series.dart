import 'dart:math';

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
import 'package:deriv_chart/src/theme/painting_styles/data_series_style.dart';
import 'package:flutter/material.dart';

import '../../../../deriv_chart.dart';
import '../../chart_data.dart';
import '../series_painter.dart';
import 'models/ma_env_options.dart';

/// A series which shows Moving Average Envelope data calculated from 'entries'.
class MAEnvSeries extends Series {
  /// Initializes a series which shows shows moving Average data calculated from [entries].
  ///
  /// [maEnvOptions] Moving Average Envelope indicator options.
  MAEnvSeries(
    List<Tick> entries, {
    String id,
    MAEnvOptions maEnvOptions,
  }) : this.fromIndicator(
          CloseValueIndicator(entries),
          id: id,
          maEnvOptions: maEnvOptions,
        );

  /// Initializes
  MAEnvSeries.fromIndicator(
    Indicator indicator, {
    String id,
    this.maEnvOptions,
  })  : _fieldIndicator = indicator,
        super(id);

  final Indicator _fieldIndicator;

  /// Moving Average Envelope options
  MAEnvOptions maEnvOptions;

  SingleIndicatorSeries _lowerSeries;
  SingleIndicatorSeries _middleSeries;
  SingleIndicatorSeries _upperSeries;

  @override
  SeriesPainter<Series> createPainter() {
    final CachedIndicator smaIndicator =
        MASeries.getMAIndicator(_fieldIndicator, maEnvOptions);

    _lowerSeries = SingleIndicatorSeries(
      painterCreator: (
        Series series,
      ) =>
          LinePainter(series),
      indicatorCreator: () => MAEnvLowerIndicator(
        smaIndicator,
        maEnvOptions.shiftType,
        maEnvOptions.shift,
      ),
      inputIndicator: _fieldIndicator,
      options: maEnvOptions,
      style: const LineStyle(color: Colors.red),
    );

    _middleSeries = SingleIndicatorSeries(
      painterCreator: (Series series) => LinePainter(series),
      indicatorCreator: () => smaIndicator,
      inputIndicator: _fieldIndicator,
      options: maEnvOptions,
      style: const LineStyle(color: Colors.blue),
    );

    _upperSeries = SingleIndicatorSeries(
      painterCreator: (Series series) => LinePainter(series),
      indicatorCreator: () => MAEnvUpperIndicator(
        smaIndicator,
        maEnvOptions.shiftType,
        maEnvOptions.shift,
      ),
      inputIndicator: _fieldIndicator,
      options: maEnvOptions,
      style: const LineStyle(color: Colors.green),
    );
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
