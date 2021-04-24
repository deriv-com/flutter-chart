// @dart=2.9

import 'dart:math';
import 'dart:ui' as ui;

import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/indicators_ui/donchian_channel/donchian_channel_indicator_config.dart';
import 'package:deriv_chart/src/logic/chart_data.dart';
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

    return null; // TODO(ramin): return the painter that paints Channel Fill between bands
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
    _upperChannelSeries.paint(
        canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);
    _middleChannelSeries.paint(
        canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);
    _lowerChannelSeries.paint(
        canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);

    if (config.showChannelFill &&
        _upperChannelSeries.visibleEntries.isNotEmpty &&
        _lowerChannelSeries.visibleEntries.isNotEmpty) {
      final Path fillPath = Path()
        ..moveTo(
          epochToX(_upperChannelSeries.getEpochOf(
            _upperChannelSeries.visibleEntries.first,
            _upperChannelSeries.visibleEntries.startIndex,
          )),
          quoteToY(_upperChannelSeries.visibleEntries.first.quote),
        );

      // Skip first (starting point) and last (can be animated).
      for (final Tick tick in _upperChannelSeries.visibleEntries.entries
          .skip(1)
          .take(_upperChannelSeries.visibleEntries.length - 2)) {}

      for (int i = _upperChannelSeries.visibleEntries.startIndex + 1;
          i < _upperChannelSeries.visibleEntries.endIndex - 1;
          i++) {
        final Tick tick = _upperChannelSeries.entries[i];
        fillPath.lineTo(
          epochToX(_upperChannelSeries.getEpochOf(tick, i)),
          quoteToY(tick.quote),
        );
      }

      // Check for animated upper tick.
      final Tick lastUpperTick = _upperChannelSeries.entries.last;
      final Tick lastUpperVisibleTick = _upperChannelSeries.visibleEntries.last;
      double lastVisibleTickX;

      if (lastUpperTick == lastUpperVisibleTick &&
          _upperChannelSeries.prevLastEntry != null) {
        lastVisibleTickX = ui.lerpDouble(
          epochToX(_upperChannelSeries.getEpochOf(
            _upperChannelSeries.prevLastEntry.entry,
            _upperChannelSeries.prevLastEntry.index,
          )),
          epochToX(lastUpperTick.epoch),
          animationInfo.currentTickPercent,
        );

        final double tickY = quoteToY(ui.lerpDouble(
          _upperChannelSeries.prevLastEntry.entry.quote,
          lastUpperTick.quote,
          animationInfo.currentTickPercent,
        ));

        fillPath.lineTo(lastVisibleTickX, tickY);
      } else {
        lastVisibleTickX = epochToX(lastUpperVisibleTick.epoch);
        fillPath.lineTo(lastVisibleTickX, quoteToY(lastUpperVisibleTick.quote));
      }

      // Check for animated lower tick.
      final Tick lastLowerTick = _lowerChannelSeries.entries.last;
      final Tick lastLowerVisibleTick = _lowerChannelSeries.visibleEntries.last;

      if (lastLowerTick == lastLowerVisibleTick &&
          _lowerChannelSeries.prevLastEntry != null) {
        lastVisibleTickX = ui.lerpDouble(
          epochToX(_lowerChannelSeries.getEpochOf(
            _lowerChannelSeries.prevLastEntry.entry,
            _lowerChannelSeries.prevLastEntry.index,
          )),
          epochToX(lastLowerTick.epoch),
          animationInfo.currentTickPercent,
        );

        final double tickY = quoteToY(ui.lerpDouble(
          _lowerChannelSeries.prevLastEntry.entry.quote,
          lastLowerTick.quote,
          animationInfo.currentTickPercent,
        ));

        fillPath.lineTo(lastVisibleTickX, tickY);
      } else {
        lastVisibleTickX = epochToX(lastLowerVisibleTick.epoch);
        fillPath.lineTo(lastVisibleTickX, quoteToY(lastLowerVisibleTick.quote));
      }

      for (int i = _lowerChannelSeries.visibleEntries.endIndex - 1;
          i >= _lowerChannelSeries.visibleEntries.startIndex;
          i--) {
        final Tick tick = _lowerChannelSeries.entries[i];
        fillPath.lineTo(
          epochToX(_lowerChannelSeries.getEpochOf(tick, i)),
          quoteToY(tick.quote),
        );
      }

      fillPath.close();

      paintFill(
        canvas,
        fillPath,
        config.fillColor,
      );
    }
  }

  // min/max epoch for all 3 channels are equal, using only `_loweChannelSeries` min/max.
  @override
  int getMaxEpoch() => _lowerChannelSeries.getMaxEpoch();

  @override
  int getMinEpoch() => _lowerChannelSeries.getMinEpoch();
}
