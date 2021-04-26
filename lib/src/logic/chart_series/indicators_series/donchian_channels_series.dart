import 'dart:math';
import 'dart:ui' as ui;

import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/indicators_ui/donchian_channel/donchian_channel_indicator_config.dart';
import 'package:deriv_chart/src/logic/chart_data.dart';
import 'package:deriv_chart/src/logic/chart_series/line_series/channel_fill_painter.dart';
import 'package:deriv_chart/src/logic/chart_series/line_series/line_series.dart';
import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/logic/chart_series/series_painter.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/paint/paint_fill.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';
import 'package:flutter/material.dart';

/// Donchian Channels series
class DonchianChannelsSeries extends Series {
  /// Initializes
  DonchianChannelsSeries(
    IndicatorInput indicatorInput, {
    String id,
  }) : this.fromIndicator(
          HighValueIndicator<Tick>(indicatorInput),
          LowValueIndicator<Tick>(indicatorInput),
          const DonchianChannelIndicatorConfig(),
          id: id,
        );

  /// Initializes
  DonchianChannelsSeries.fromIndicator(
    HighValueIndicator<Tick> highIndicator,
    LowValueIndicator<Tick> lowIndicator,
    this.config, {
    String id,
  })  : _highIndicator = highIndicator,
        _lowIndicator = lowIndicator,
        super(id);

  LineSeries _upperChannelSeries;
  LineSeries _middleChannelSeries;
  LineSeries _lowerChannelSeries;

  final HighValueIndicator<Tick> _highIndicator;
  final LowValueIndicator<Tick> _lowIndicator;

  /// Configuration of donchian channels.
  final DonchianChannelIndicatorConfig config;

  @override
  SeriesPainter<Series> createPainter() {
    final HighestValueIndicator<Tick> upperChannelIndicator =
        HighestValueIndicator<Tick>(
      _highIndicator,
      config.highPeriod,
    )..calculateValues();

    final LowestValueIndicator<Tick> lowerChannelIndicator =
        LowestValueIndicator<Tick>(
      _lowIndicator,
      config.lowPeriod,
    )..calculateValues();

    final DonchianMiddleChannelIndicator<Tick> middleChannelIndicator =
        DonchianMiddleChannelIndicator<Tick>(
      upperChannelIndicator,
      lowerChannelIndicator,
    )..calculateValues();

    _upperChannelSeries = LineSeries(
      upperChannelIndicator.results,
      style: config.upperLineStyle,
    );

    _lowerChannelSeries = LineSeries(
      lowerChannelIndicator.results,
      style: config.lowerLineStyle,
    );

    _middleChannelSeries = LineSeries(
      middleChannelIndicator.results,
      style: config.middleLineStyle,
    );

    final ChannelFillPainter fillPainter = ChannelFillPainter(
      _upperChannelSeries,
      _lowerChannelSeries,
      fillColor: config.fillColor,
      hasChannelFill: config.showChannelFill,
    );

    return fillPainter; // TODO(ramin): return the painter that paints Channel Fill between bands
  }

  @override
  bool didUpdate(ChartData oldData) {
    final DonchianChannelsSeries oldSeries = oldData;

    final bool upperUpdated =
        _upperChannelSeries.didUpdate(oldSeries?._upperChannelSeries);
    final bool middleUpdated =
        _middleChannelSeries.didUpdate(oldSeries?._middleChannelSeries);
    final bool lowerUpdated =
        _lowerChannelSeries.didUpdate(oldSeries?._lowerChannelSeries);

    return upperUpdated || middleUpdated || lowerUpdated;
  }

  @override
  void onUpdate(int leftEpoch, int rightEpoch) {
    _upperChannelSeries.update(leftEpoch, rightEpoch);
    _middleChannelSeries.update(leftEpoch, rightEpoch);
    _lowerChannelSeries.update(leftEpoch, rightEpoch);
  }

  @override
  List<double> recalculateMinMax() => <double>[
        _lowerChannelSeries.minValue,
        _upperChannelSeries.maxValue,
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
    // _middleChannelSeries.paint(
    //     canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);

    super.paint(
        canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);
  }

  // min/max epoch for all 3 channels are equal, using only `_loweChannelSeries` min/max.
  @override
  int getMaxEpoch() => _lowerChannelSeries.getMaxEpoch();

  @override
  int getMinEpoch() => _lowerChannelSeries.getMinEpoch();
}
