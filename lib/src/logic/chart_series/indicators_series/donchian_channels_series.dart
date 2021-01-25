import 'dart:ui' as ui;

import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/indicators_ui/donchian_channel/donchian_channel_indicator_config.dart';
import 'package:deriv_chart/src/logic/chart_data.dart';
import 'package:deriv_chart/src/logic/chart_series/line_series/line_series.dart';
import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/logic/chart_series/series_painter.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/donchian/donchian_middle_channel_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/helper_indicators/high_value_inidicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/helper_indicators/low_value_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/highest_value_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/lowest_value_indicator.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/paint/paint_fill.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:flutter/material.dart';

/// Donchian Channels series
class DonchianChannelsSeries extends Series {
  /// Initializes
  DonchianChannelsSeries(
    List<Tick> ticks, {
    String id,
  }) : this.fromIndicator(
          HighValueIndicator(ticks),
          LowValueIndicator(ticks),
          const DonchianChannelIndicatorConfig(),
          id: id,
        );

  /// Initializes
  DonchianChannelsSeries.fromIndicator(
    HighValueIndicator highIndicator,
    LowValueIndicator lowIndicator,
    this.config, {
    String id,
  })  : _highIndicator = highIndicator,
        _lowIndicator = lowIndicator,
        super(id);

  LineSeries _upperChannelSeries;
  LineSeries _middleChannelSeries;
  LineSeries _lowerChannelSeries;

  final HighValueIndicator _highIndicator;
  final LowValueIndicator _lowIndicator;

  /// Configuration of donchian channels.
  final DonchianChannelIndicatorConfig config;

  @override
  SeriesPainter<Series> createPainter() {
    final HighestValueIndicator upperChannelIndicator = HighestValueIndicator(
      _highIndicator,
      config.highPeriod,
    );

    final LowestValueIndicator lowerChannelIndicator = LowestValueIndicator(
      _lowIndicator,
      config.lowPeriod,
    );

    final DonchianMiddleChannelIndicator middleChannelIndicator =
        DonchianMiddleChannelIndicator(
            upperChannelIndicator, lowerChannelIndicator);

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
    final DonchianChannelsSeries series = oldData;

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
          epochToX(_upperChannelSeries.visibleEntries.first.epoch),
          quoteToY(_upperChannelSeries.visibleEntries.first.quote),
        );

      // Skip first (starting point) and last (can be animated).
      for (final Tick tick in _upperChannelSeries.visibleEntries
          .skip(1)
          .take(_upperChannelSeries.visibleEntries.length - 2)) {
        fillPath.lineTo(
          epochToX(tick.epoch),
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
          epochToX(_upperChannelSeries.prevLastEntry.epoch),
          epochToX(lastUpperTick.epoch),
          animationInfo.currentTickPercent,
        );

        final double tickY = quoteToY(ui.lerpDouble(
          _upperChannelSeries.prevLastEntry.quote,
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
          epochToX(_lowerChannelSeries.prevLastEntry.epoch),
          epochToX(lastLowerTick.epoch),
          animationInfo.currentTickPercent,
        );

        final double tickY = quoteToY(ui.lerpDouble(
          _lowerChannelSeries.prevLastEntry.quote,
          lastLowerTick.quote,
          animationInfo.currentTickPercent,
        ));

        fillPath.lineTo(lastVisibleTickX, tickY);
      } else {
        lastVisibleTickX = epochToX(lastLowerVisibleTick.epoch);
        fillPath.lineTo(lastVisibleTickX, quoteToY(lastUpperVisibleTick.quote));
      }

      for (final Tick tick
          in _lowerChannelSeries.visibleEntries.reversed.skip(1)) {
        fillPath.lineTo(
          epochToX(tick.epoch),
          quoteToY(tick.quote),
        );
      }

      fillPath.close();

      paintFill(
        canvas,
        fillPath,
        // TODO: pass from config
        Colors.white10,
      );
    }
  }
}
