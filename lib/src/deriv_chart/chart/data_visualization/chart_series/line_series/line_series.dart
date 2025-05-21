import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/crosshair_behaviour/crosshair_behaviour.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/crosshair_behaviour/line_series_crosshair_behaviour.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/crosshair_highlight_painter.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/crosshair_line_highlight_painter.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/factory/crosshair_behaviour_factory.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/theme/painting_styles/barrier_style.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';

import '../data_series.dart';
import '../series_painter.dart';
import 'line_painter.dart';

/// Line series.
class LineSeries extends DataSeries<Tick> {
  /// Initializes a line series.
  LineSeries(
    List<Tick> entries, {
    String? id,
    LineStyle? style,
    HorizontalBarrierStyle? lastTickIndicatorStyle,
  }) : super(
          entries,
          id: id ?? 'LineSeries',
          style: style,
          lastTickIndicatorStyle: lastTickIndicatorStyle,
        );

  @override
  SeriesPainter<DataSeries<Tick>> createPainter() => LinePainter(
        this,
      );

  @override
  Widget getCrossHairInfo(Tick crossHairTick, int pipSize, ChartTheme theme) =>
      Text(
        '${crossHairTick.quote.toStringAsFixed(pipSize)}',
        style: theme.crosshairInformationBoxQuoteStyle.copyWith(
          color: theme.crosshairInformationBoxTextDefault,
        ),
      );

  @override
  Widget getDetailedCrossHairInfo({
    required Tick crosshairTick,
    required int pipSize,
    required ChartTheme theme,
  }) =>
      getCrossHairInfo(crosshairTick, pipSize, theme);

  @override
  double maxValueOf(Tick t) => t.quote;

  @override
  double minValueOf(Tick t) => t.quote;

  @override
  CrosshairBehaviourFactory<CrosshairBehaviour<Tick>>
      getCrosshairBehaviourFactory() {
    return CrosshairBehaviourFactory(
      smallScreenBehaviourBuilder: () => LineSeriesSmallScreenBehaviour(),
      largeScreenBehaviourBuilder: () => LineSeriesLargeScreenBehaviour(),
    );
  }

  @override
  CrosshairHighlightPainter getCrosshairHighlightPainter(
      Tick crosshairTick,
      double Function(double p1) quoteToY,
      double xCenter,
      double elementWidth,
      ChartTheme theme) {
    // Return a CrosshairLineHighlightPainter with transparent colors
    // This effectively creates a "no-op" painter that doesn't paint anything visible
    return CrosshairLineHighlightPainter(
      tick: crosshairTick,
      quoteToY: quoteToY,
      xCenter: xCenter,
      pointColor: Colors.transparent,
      pointSize: 0,
    );
  }
}
