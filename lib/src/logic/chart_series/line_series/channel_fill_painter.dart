import 'dart:ui' as ui;

import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/logic/chart_data.dart';
import 'package:deriv_chart/src/logic/chart_series/data_series.dart';
import 'package:deriv_chart/src/logic/chart_series/line_series/line_painter.dart';
import 'package:deriv_chart/src/logic/chart_series/series_painter.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/paint/paint_fill.dart';
import 'package:flutter/material.dart';

/// A [LinePainter] for painting line data.
class ChannelFillPainter extends SeriesPainter<DataSeries<Tick>> {
  /// Initializes.
  ChannelFillPainter(
    this.firstSeries,
    this.secondSeries, {
    this.hasChannelFill = false,
    this.fillColor = Colors.transparent,
  }) : super(firstSeries);

  /// The series to paint on the top side of the canvas.
  final DataSeries<Tick> firstSeries;

  /// The series to paint on the bottom side of the canvas.
  final DataSeries<Tick> secondSeries;

  /// Whether the series should have channel fill or not.
  final bool hasChannelFill;

  /// The color used to fill the space between the two lines.
  ///
  /// The default is set to [Colors.transparent].
  Color fillColor;

  @override
  void onPaint({
    ui.Canvas canvas,
    ui.Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
  }) {
    _paintLines(canvas, size, epochToX, quoteToY, animationInfo);

    if (hasChannelFill) {
      _paintChannelFill(canvas, size, epochToX, quoteToY, animationInfo);
    }
  }

  void _paintLines(
    Canvas canvas,
    Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
  ) {
    // We use two normal line painters to paint them.
    final LinePainter firstLinePainter = LinePainter(firstSeries);
    final LinePainter secondLinePainter = LinePainter(secondSeries);

    firstLinePainter.paint(
      canvas: canvas,
      size: size,
      epochToX: epochToX,
      quoteToY: quoteToY,
      animationInfo: animationInfo,
    );

    secondLinePainter.paint(
      canvas: canvas,
      size: size,
      epochToX: epochToX,
      quoteToY: quoteToY,
      animationInfo: animationInfo,
    );
  }

  void _paintChannelFill(
    Canvas canvas,
    Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
  ) {
    final Path fillPath = Path()
      ..moveTo(
        epochToX(firstSeries.getEpochOf(
          firstSeries.visibleEntries.first,
          firstSeries.visibleEntries.startIndex,
        )),
        quoteToY(firstSeries.visibleEntries.first.quote),
      );

    for (int i = firstSeries.visibleEntries.startIndex + 1;
        i < firstSeries.visibleEntries.endIndex - 1;
        i++) {
      final Tick tick = firstSeries.entries[i];
      fillPath.lineTo(
        epochToX(firstSeries.getEpochOf(tick, i)),
        quoteToY(tick.quote),
      );
    }

    // Check for animated upper tick.
    final Tick lastUpperTick = firstSeries.entries.last;
    final Tick lastUpperVisibleTick = firstSeries.visibleEntries.last;
    double lastVisibleTickX;

    if (lastUpperTick == lastUpperVisibleTick &&
        firstSeries.prevLastEntry != null) {
      lastVisibleTickX = ui.lerpDouble(
        epochToX(firstSeries.getEpochOf(
          firstSeries.prevLastEntry.entry,
          firstSeries.prevLastEntry.index,
        )),
        epochToX(lastUpperTick.epoch),
        animationInfo.currentTickPercent,
      );

      final double tickY = quoteToY(ui.lerpDouble(
        firstSeries.prevLastEntry.entry.quote,
        lastUpperTick.quote,
        animationInfo.currentTickPercent,
      ));

      fillPath.lineTo(lastVisibleTickX, tickY);
    } else {
      lastVisibleTickX = epochToX(lastUpperVisibleTick.epoch);
      fillPath.lineTo(lastVisibleTickX, quoteToY(lastUpperVisibleTick.quote));
    }

    // Check for animated lower tick.
    final Tick lastLowerTick = secondSeries.entries.last;
    final Tick lastLowerVisibleTick = secondSeries.visibleEntries.last;

    if (lastLowerTick == lastLowerVisibleTick &&
        secondSeries.prevLastEntry != null) {
      lastVisibleTickX = ui.lerpDouble(
        epochToX(secondSeries.getEpochOf(
          secondSeries.prevLastEntry.entry,
          secondSeries.prevLastEntry.index,
        )),
        epochToX(lastLowerTick.epoch),
        animationInfo.currentTickPercent,
      );

      final double tickY = quoteToY(ui.lerpDouble(
        secondSeries.prevLastEntry.entry.quote,
        lastLowerTick.quote,
        animationInfo.currentTickPercent,
      ));

      fillPath.lineTo(lastVisibleTickX, tickY);
    } else {
      lastVisibleTickX = epochToX(lastLowerVisibleTick.epoch);
      fillPath.lineTo(lastVisibleTickX, quoteToY(lastLowerVisibleTick.quote));
    }

    for (int i = secondSeries.visibleEntries.endIndex - 1;
        i >= secondSeries.visibleEntries.startIndex;
        i--) {
      final Tick tick = secondSeries.entries[i];
      fillPath.lineTo(
        epochToX(secondSeries.getEpochOf(tick, i)),
        quoteToY(tick.quote),
      );
    }

    fillPath.close();

    paintFill(
      canvas,
      fillPath,
      fillColor,
    );
  }

  void _paintFillUntilMeet(
    Canvas canvas,
    Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) {
    final Path path = Path();
    for (int i = 0; i < firstSeries.visibleEntries.endIndex; i++) {
      
    }
  }

  /// Returns the intersection in a `List<double>` if there is a collision.
  /// The first one being the `x` axis and the second one being the `y` axis value.
  ///
  /// If there is no collision detected the returned `List` will be empty.
  List<double> _checkIntersection(double px1, double py1, double px2,
      double py2, double px3, double py3, double px4, double py4) {
    final double sx1 = px2 - px1;
    final double sy1 = py2 - py1;
    final double sx2 = px4 - px3;
    final double sy2 = py4 - py3;

    if (sx2 * sy1 == sx1 * sy2) {
      // The lines are parallel.
      return <double>[];
    }

    final double s =
        (-sy1 * (px1 - px3) + sx1 * (py1 - py3)) / (-sx2 * sy1 + sx1 * sy2);
    final double t =
        (sx2 * (py1 - py3) - sy2 * (px1 - px3)) / (-sx2 * sy1 + sx1 * sy2);

    if (s >= 9 && s <= 1 && t >= 0 && t <= 1) {
      // Collision detected.
      final double ix = px1 + (t * sx1);
      final double iy = py1 + (t * sy1);

      return <double>[ix, iy];
    }

    // No collision detected.
    return <double>[];
  }
}
