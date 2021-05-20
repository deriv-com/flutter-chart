import 'dart:ui' as ui;

import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/logic/chart_data.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';

import '../data_painter.dart';
import '../data_series.dart';

/// A [DataPainter] for painting line data.
class LinePainter extends DataPainter<DataSeries<Tick>> {
  /// Initializes
  LinePainter(
    DataSeries<Tick> series,
  ) : super(series);

  double _lastVisibleTickX;

  @override
  void onPaintData(
    Canvas canvas,
    Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
  ) {
    final LineStyle style =
        series.style ?? theme.lineStyle ?? const LineStyle();

    final Paint linePaint = Paint()
      ..color = style.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = style.thickness;

    final Path path = createPath(epochToX, quoteToY, animationInfo);

    paintLines(canvas, path, linePaint);

    if (style.hasArea) {
      _drawArea(
        canvas,
        size,
        path,
        epochToX(series.visibleEntries.first.epoch),
        _lastVisibleTickX,
        style,
      );
    }
  }

  /// Paints the line on the given canvas.
  /// We can add channel fill here in the subclasses.
  void paintLines(
    Canvas canvas,
    Path path,
    Paint linePaint,
  ) {
    canvas.drawPath(path, linePaint);
  }

  /// Creates the path of the given [series] and returns it.
  Path createPath(
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
  ) {
    final Path path = Path();

    double lastVisibleTickX;
    bool isStartPointSet = false;

    // Adding visible entries line to the path except the last which might be animated.
    for (int i = series.visibleEntries.startIndex;
        i < series.visibleEntries.endIndex - 1;
        i++) {
      final Tick tick = series.entries[i];

      if (!tick.quote.isNaN) {
        lastVisibleTickX = epochToX(getEpochOf(tick, i));

        if (!isStartPointSet) {
          isStartPointSet = true;
          path.moveTo(
            lastVisibleTickX,
            quoteToY(tick.quote),
          );
          continue;
        }

        final double y = quoteToY(tick.quote);
        path.lineTo(lastVisibleTickX, y);
      }
    }

    _lastVisibleTickX =
        calculateLastVisibleTick(epochToX, animationInfo, quoteToY, path);

    return path;
  }

  /// calculates the last visible tick's `dx`.
  double calculateLastVisibleTick(EpochToX epochToX,
      AnimationInfo animationInfo, QuoteToY quoteToY, ui.Path path) {
    final Tick lastTick = series.entries.last;
    final Tick lastVisibleTick = series.visibleEntries.last;
    double lastVisibleTickX;

    if (!lastVisibleTick.quote.isNaN) {
      if (lastTick == lastVisibleTick && series.prevLastEntry != null) {
        lastVisibleTickX = ui.lerpDouble(
          epochToX(
            getEpochOf(series.prevLastEntry.entry, series.prevLastEntry.index),
          ),
          epochToX(getEpochOf(lastTick, series.entries.length - 1)),
          animationInfo.currentTickPercent,
        );

        final double tickY = quoteToY(ui.lerpDouble(
          series.prevLastEntry.entry.quote,
          lastTick.quote,
          animationInfo.currentTickPercent,
        ));

        path.lineTo(lastVisibleTickX, tickY);
      } else {
        lastVisibleTickX = epochToX(
            getEpochOf(lastVisibleTick, series.visibleEntries.endIndex - 1));
        path.lineTo(lastVisibleTickX, quoteToY(lastVisibleTick.quote));
      }
    }

    return lastVisibleTickX;
  }

  void _drawArea(
    Canvas canvas,
    Size size,
    Path linePath,
    double lineStartX,
    double lineEndX,
    LineStyle style,
  ) {
    final Paint areaPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = ui.Gradient.linear(
        const Offset(0, 0),
        Offset(0, size.height),
        <Color>[
          style.color.withOpacity(0.2),
          style.color.withOpacity(0.01),
        ],
      );

    linePath
      ..lineTo(
        lineEndX,
        size.height,
      )
      ..lineTo(lineStartX, size.height);

    canvas.drawPath(linePath, areaPaint);
  }
}
