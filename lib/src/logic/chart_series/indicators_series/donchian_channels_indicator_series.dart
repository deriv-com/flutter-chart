import 'dart:math';

import 'package:deriv_chart/src/logic/chart_data.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/ma_series.dart';
import 'package:deriv_chart/src/logic/chart_series/line_series/line_series.dart';
import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/logic/chart_series/series_painter.dart';
import 'package:deriv_chart/src/logic/indicators/cached_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/bollinger/bollinger_bands_lower_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/helper_indicators/close_value_inidicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/bollinger/bollinger_bands_upper_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/statistics/standard_deviation_indicator.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';

/// Bollinger bands series
class DonchianChannelsIndicatorSeries extends Series {
  /// Initializes
  ///
  /// Close values will be chosen by default.
  DonchianChannelsIndicatorSeries(
    List<Tick> ticks, {
    int period = 20,
    MovingAverageType movingAverageType = MovingAverageType.simple,
    double standardDeviationFactor = 2,
    String id,
  }) : this.fromIndicator(
          CloseValueIndicator(ticks),
          period: period,
          movingAverageType: movingAverageType,
          standardDeviationFactor: standardDeviationFactor,
          id: id,
        );

  /// Initializes
  DonchianChannelsIndicatorSeries.fromIndicator(
    Indicator indicator, {
    this.period = 20,
    this.movingAverageType = MovingAverageType.simple,
    this.standardDeviationFactor = 2,
    String id,
  })  : _fieldIndicator = indicator,
        super(id);

  LineSeries _upperChannelSeries;
  LineSeries _middleChannelSeries;
  LineSeries _lowerChannelSeries;

  /// Period
  final int period;

  /// Bollinger Bands Moving Average type
  final MovingAverageType movingAverageType;

  /// Standard Deviation value
  final double standardDeviationFactor;

  final Indicator _fieldIndicator;

  @override
  SeriesPainter<Series> createPainter() {
    // final StandardDeviationIndicator standardDeviation =
    //     StandardDeviationIndicator(_fieldIndicator, period);

    // final CachedIndicator bbmSMA =
    //     MASeries.getMAIndicator(_fieldIndicator, period, movingAverageType);

    // final BollingerBandsLowerIndicator bblSMA = BollingerBandsLowerIndicator(
    //   bbmSMA,
    //   standardDeviation,
    //   k: standardDeviationFactor,
    // );

    // final BollingerBandsUpperIndicator bbuSMA = BollingerBandsUpperIndicator(
    //   bbmSMA,
    //   standardDeviation,
    //   k: standardDeviationFactor,
    // );

    // _lowerSeries = LineSeries(bblSMA.results,
    //     style: const LineStyle(color: Colors.redAccent));
    // _middleSeries =
    //     LineSeries(bbmSMA.results, style: const LineStyle(color: Colors.white));
    // _upperSeries = LineSeries(bbuSMA.results,
    //     style: const LineStyle(color: Colors.lightGreen));

    return null; // TODO(ramin): return the painter that paints Channel Fill between bands
  }

  @override
  bool didUpdate(ChartData oldData) {
    final DonchianChannelsIndicatorSeries series = oldData;

    final bool _upperChannelUpdated =
        _upperChannelSeries.didUpdate(series._upperChannelSeries);
    final bool _middleChannelUpdated =
        _middleChannelSeries.didUpdate(series._middleChannelSeries);
    final bool _lowerChannelUpdated =
        _lowerChannelSeries.didUpdate(series._lowerChannelSeries);

    return _upperChannelUpdated ||
        _middleChannelUpdated ||
        _lowerChannelUpdated;
  }

  @override
  void onUpdate(int leftEpoch, int rightEpoch) {
    _upperChannelSeries.update(leftEpoch, rightEpoch);
    _middleChannelSeries.update(leftEpoch, rightEpoch);
    _lowerChannelSeries.update(leftEpoch, rightEpoch);
  }

  @override
  List<double> recalculateMinMax() =>
      <double>[_lowerChannelSeries.minValue, _upperChannelSeries.maxValue];

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
    _upperChannelSeries.paint(
        canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);
    _middleChannelSeries.paint(
        canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);
    _lowerChannelSeries.paint(
        canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);

    // TODO(ramin): call super.paint to paint the Channels fill.
  }
}
