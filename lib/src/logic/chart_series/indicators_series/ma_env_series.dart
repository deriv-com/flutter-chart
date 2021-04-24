// @dart=2.9

import 'package:deriv_chart/src/helpers/helper_functions.dart';
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
import 'models/ma_env_options.dart';

/// A series which shows Moving Average Envelope data calculated from 'entries'.
class MAEnvSeries extends Series {
  /// Initializes a series which shows shows moving Average data calculated from [entries].
  ///
  /// [maEnvOptions] Moving Average Envelope indicator options.
  MAEnvSeries(
    IndicatorInput indicatorInput, {
    String id,
    MAEnvOptions maEnvOptions,
  }) : this.fromIndicator(
          CloseValueIndicator<Tick>(indicatorInput),
          id: id,
          maEnvOptions: maEnvOptions,
        );

  /// Initializes
  MAEnvSeries.fromIndicator(
    Indicator<Tick> indicator, {
    String id,
    this.maEnvOptions,
  })  : _fieldIndicator = indicator,
        super(id);

  final Indicator<Tick> _fieldIndicator;

  /// Moving Average Envelope options
  MAEnvOptions maEnvOptions;

  SingleIndicatorSeries _lowerSeries;
  SingleIndicatorSeries _middleSeries;
  SingleIndicatorSeries _upperSeries;

  final List<Series> _innerSeries = <Series>[];

  @override
  SeriesPainter<Series> createPainter() {
    final CachedIndicator<Tick> smaIndicator =
        MASeries.getMAIndicator(_fieldIndicator, maEnvOptions);

    _lowerSeries = SingleIndicatorSeries(
      painterCreator: (
        Series series,
      ) =>
          LinePainter(series),
      indicatorCreator: () => MAEnvLowerIndicator<Tick>(
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
      indicatorCreator: () => MAEnvUpperIndicator<Tick>(
        smaIndicator,
        maEnvOptions.shiftType,
        maEnvOptions.shift,
      ),
      inputIndicator: _fieldIndicator,
      options: maEnvOptions,
      style: const LineStyle(color: Colors.green),
    );

    _innerSeries..add(_lowerSeries)..add(_middleSeries)..add(_upperSeries);

    return null;
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
      // TODO(Ramin): Maybe later we can have these code and getMin/MaxEpochs in a parent class for Indicators like MAEnv, Ichimoku, Bollinger, etc
      <double>[
        _innerSeries
            .map((Series series) => series.minValue)
            .reduce((double a, double b) => safeMin(a, b)),
        _innerSeries
            .map((Series series) => series.maxValue)
            .reduce((double a, double b) => safeMax(a, b)),
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

  @override
  int getMaxEpoch() => _innerSeries.getMaxEpoch();

  @override
  int getMinEpoch() => _innerSeries.getMinEpoch();
}
